///|
pub(all) enum Path {
  WPath(WinPath)
  UPath(UnixPath)
} derive(ToJson, Hash, Eq)

///|
fn parse_windows_relative_path(
  s : StringView,
  start~ : Int,
) -> (WinDirectory, WinFile?) raise PathError {
  let mut rest = s
  let directory : Array[WinPathComponent] = []
  let mut start = start
  let file : WinFile? = for {
    lexmatch rest with longest {
      ((("[^\\]+" as s) "\\") as all, r) => {
        directory.push(WinPathComponent::from(s, start~))
        start = all.char_length()
        rest = r
      }
      (("[^\\.]+" as base) "\." ("[^\\]+" as extension)) =>
        break Some(WinFile::new(base~, extension~))
      ("[^\\.]+" as base) => break Some(WinFile::new(base~))
      "$" => break None
      _ => raise PathError(start~, message="Invalid Windows path")
    }
  }
  (Directory(FixedArray::from_array(directory)), file)
}

///|
fn parse_unix_relative_path(
  s : StringView,
  start~ : Int,
) -> (UnixDirectory, UnixFile?) raise PathError {
  raise PathError::PathError(
    start=0,
    message="Unix path parsing not implemented: '\{s}'",
  )
}

///|
pub fn Path::parse(s : String) -> Path raise PathError {
  lexmatch s with longest {
    ("\\\\\?\\" as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(WinPath::new(directory~, file?))
    }
    (("\\\\\?" ("[^\\]+" as symlink) "\\") as prefix, rest) => {
      // TODO: check symlink name 
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(
        WinPath::new(
          prefix=Verbatim(symlink=symlink.to_string()),
          directory~,
          file?,
        ),
      )
    }
    (
      (
        "\\\\\?UNC\\"
        ("[^\\]+" as hostname)
        "\\"
        ("[^\\]+" as shared_folder)
        "\\"
      ) as prefix,
      rest
    ) => {
      // TODO: check hostname and shared_folder
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(
        WinPath::new(
          prefix=VerbatimUNC(
            hostname=hostname.to_string(),
            shared_folder=shared_folder.to_string(),
          ),
          directory~,
          file?,
        ),
      )
    }
    (("\\\\\?" ("[a-zA-Z]" as letter) ":\\") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(
        WinPath::new(prefix=VerbatimVolumeLetter(letter), directory~, file?),
      )
    }
    (("\\\\\?Volume[{]" ("[^}]+" as guid) "[}]") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(
        WinPath::new(
          prefix=VerbatimVolumeGUID(guid.to_string()),
          directory~,
          file?,
        ),
      )
    }
    // check the device 
    (("\\\\\.\\" ("[^\\]+" as device) "\\") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(
        WinPath::new(
          prefix=DeviceNS(device=device.to_string()),
          directory~,
          file?,
        ),
      )
    }
    ((("[a-zA-Z]" as letter) ":\\") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(WinPath::new(prefix=VolumeLetter(letter), directory~, file?))
    }
    // current path 
    ("\.\\" as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(WinPath::new(directory~, file?))
    }
    // root path but without derive letter
    ("\\\.\." as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
      )
      WPath(WinPath::new(directory~, file?))
    }
    // root path but without derive letter 
    ("\\" as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.utf16_len(),
      )
      WPath(WinPath::new(directory~, file?))
    }
    // current path 
    ("\./" as prefix, rest) => {
      let (directory, file) = parse_unix_relative_path(
        rest,
        start=prefix.char_length(),
      )
      UPath(UnixPath::new(directory~, file?))
    }
    // root path 
    ("/\.\." as prefix, rest) => {
      let (directory, file) = parse_unix_relative_path(
        rest,
        start=prefix.char_length(),
      )
      UPath(UnixPath::new(is_absolute=true, directory~, file?))
    }
    // root path 
    ("/" as prefix, rest) => {
      let (directory, file) = parse_unix_relative_path(
        rest,
        start=prefix.utf16_len(),
      )
      UPath(UnixPath::new(is_absolute=true, directory~, file?))
    }
    _ =>
      // fallback attempt: treat as unix relative path (very naive placeholder)
      // let sv = s[:]
      // let (directory, file) = parse_unix_relative_path(sv)
      panic()
    // UPath(UnixPath::new(directory~, file?))
  }
}

///|
/// [Microsoft Naming a Volume](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-volume)
/// [Microsoft Naming Files, Paths, and Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)
/// [Microsoft Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
pub struct WinPath {
  prefix : WinPrefix?
  directory : WinDirectory
  file : WinFile?
} derive(ToJson, Hash, Eq)

///|
pub fn WinPath::new(
  prefix? : WinPrefix,
  directory~ : WinDirectory,
  file? : WinFile,
) -> WinPath {
  WinPath::{ prefix, directory, file }
}

///|
/// 
/// #### Verbatim Prefix
/// 
/// refer to [Microsoft Win32 File Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file#win32-file-namespaces)
/// > For file I/O,
/// > the "\\?\" prefix to a path string tells the Windows APIs to disable all string parsing and to send the string that follows it straight to the file system.
/// 
/// #### Windows Encoding 
/// 
/// refer to [Microsoft Path Unicode Normalization](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
/// 
/// > There is no need to perform any Unicode normalization on path and file name strings for use by the Windows file I/O API functions 
/// > because the file system treats path and file names as an opaque sequence of WCHARs.
/// > Any normalization that your application requires should be performed with this in mind, 
/// > external of any calls to related Windows file I/O API functions.
/// 
/// #### Relative Paths Cannot use Verbatim Prefix
/// 
/// refer to [Microsoft Verbatim restriction](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
/// 
/// > Because you cannot use the "\\?\" prefix with a relative path, 
/// > relative paths are always limited to a total of MAX_PATH characters.
/// 
pub(all) enum WinPrefix {
  /// Syntax: `\\?\<SYMLINK>\` | `\\?\`
  ///
  /// Example: `\\?\GLOBALROOT\`
  Verbatim(symlink~ : String)
  /// Syntax: `\\?\UNC\<SERVER>\<SHARE>\`
  ///
  /// Example: `\\?\UNC\server\share\`
  VerbatimUNC(hostname~ : String, shared_folder~ : String)
  /// Syntax: `\\?\<L>:\`
  ///
  /// Example: `\\?\C:\`
  VerbatimVolumeLetter(Char)
  /// Syntax: `\\?\Volume{<GUID>}`
  ///
  /// Example: `\\?\Volume{26a21bda-a627-11d7-9931-806e6f6e6963}`
  ///
  /// Warning: this letter is case-insensitive.
  ///
  /// [Microsoft Enumerating Volume GUID Paths](https://learn.microsoft.com/en-us/windows/win32/fileio/enumerating-unique-volume-names)
  VerbatimVolumeGUID(String)
  /// Syntax: `\\.\<DEVICE>\`
  ///
  /// Example: `\\.\COM56\`
  ///
  /// [Microsoft Win32 Device Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file#win32-device-namespaces)
  DeviceNS(device~ : String)
  /// Syntax: `\\<SERVER>\<SHARE>\`
  ///
  /// Example: `\\server\share\`
  UNC(hostname~ : String, shared_folder~ : String)
  /// Syntax: `<L>:\`
  ///
  /// Example: `C:\`
  ///
  /// Warning: this letter is case-insensitive.
  VolumeLetter(Char)
} derive(ToJson, Hash, Eq)

///|
let windows_reserved_names : FixedArray[String] = [
  ///
  "CON", "PRN", "AUX", "NUL",
  ///
   "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
  ///
   "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
  ///
   "COM\u00b9", "COM\u00b2", "COM\u00b3",
  ///
   "LPT\u00b9", "LPT\u00b2", "LPT\u00b3",
]

///|
fn is_windows_reserved_character(ch : Char) -> Bool {
  match ch {
    '<'
    | '>'
    | ':'
    | '\"'
    | '/'
    | '\\'
    | '|'
    | '?'
    | '*'
    | '\u0000'
    | '\u0001'..='\u0031' => true
    _ => false
  }
}

///|
/// [Posix 4.13 Pathname Resolution](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_13)
/// 
/// 
pub struct UnixPath {
  is_absolute : Bool
  directory : UnixDirectory
  file : UnixFile?
} derive(ToJson, Hash, Eq)

///|
pub fn UnixPath::new(
  is_absolute? : Bool = false,
  directory~ : UnixDirectory,
  file? : UnixFile,
) -> UnixPath {
  UnixPath::{ is_absolute, directory, file }
}

///|
pub struct File[Component] {
  base : Component
  extension : Component?
} derive(ToJson, Hash, Eq)

///|
pub fn[A : PlatformPath] File::new(
  base~ : StringView,
  extension? : StringView,
) -> File[A] raise PathError {
  let ext = if extension is Some(extension) {
    for i, ch in extension {
      guard ch != '.' else {
        raise PathError::PathError(
          start=i,
          message="Invalid file extension at position \{i}: extension '\{extension}' cannot contain '.' character",
        )
      }
    }
    Some(A::from(extension))
  } else {
    None
  }
  let base_component = A::from(base)
  File::{ base: base_component, extension: ext }
}

///|
pub typealias Directory[WinPathComponent] as WinDirectory

///|
pub typealias Directory[UnixPathComponent] as UnixDirectory

///|
pub typealias File[WinPathComponent] as WinFile

///|
pub typealias File[UnixPathComponent] as UnixFile

///|
struct Directory[Component](FixedArray[Component]) derive(ToJson, Hash, Eq)

///|
pub fn[A : PlatformPath] Directory::new(
  components : ArrayView[StringView],
) -> Directory[A] raise PathError {
  let result : Array[A] = []
  for i = 0; i < components.length(); i = i + 1 {
    result.push(A::from(components[i]))
  }
  Directory(FixedArray::from_array(result))
}

///|
pub fn[T] Directory::op_get(self : Directory[T], index : Int) -> T = "%fixedarray.get"

///|
pub fn[T] Directory::length(self : Directory[T]) -> Int = "%fixedarray.length"

///|
pub fn[T] Directory::iter(self : Directory[T]) -> Iter[T] {
  FixedArray::iter(self.0)
}

///|
#alias("_[_:_]")
pub fn[T] Directory::sub(
  self : Directory[T],
  start? : Int = 0,
  end? : Int = self.length(),
) -> ArrayView[T] {
  FixedArray::sub(self.0, start~, end~)
}

///|
struct WinPathComponent(String) derive(ToJson, Hash, Eq)

///|
struct UnixPathComponent(String) derive(ToJson, Hash, Eq)

///|
trait PlatformPath {
  from(s : StringView) -> Self raise PathError
}

///|
let windows_reserved_names_set : Set[StringView] = Set::from_iter(
  windows_reserved_names.iter().map(x => x),
)

///|
pub fn WinPathComponent::from(
  s : StringView,
  start? : Int = 0,
) -> WinPathComponent raise PathError {
  guard !s.is_empty() else {
    raise PathError::PathError(
      start=0,
      message="Windows path: empty path component not allowed",
    )
  }
  guard !windows_reserved_names_set.contains(s) else {
    raise PathError::PathError(
      start=0,
      message="Windows path: '\{s}' is a reserved name (CON, PRN, AUX, NUL, COM1-9, LPT1-9)",
    )
  }
  for i, ch in s {
    guard !is_windows_reserved_character(ch) else {
      raise PathError::PathError(
        start=start + i,
        message="Windows path: character '\{ch}' at position \{start+i} is not allowed (reserved characters: < > : \" / \\ | ? * and control characters)",
      )
    }
    guard ch != '\\' else {
      raise PathError::PathError(
        start=start + i,
        message="Windows path: backslash '\\' at position \{start+i} not allowed in path component",
      )
    }
  }
  WinPathComponent(s.to_string())
}

///|
pub fn UnixPathComponent::from(
  s : StringView,
  start~ : Int,
) -> UnixPathComponent raise PathError {
  guard !s.is_empty() else {
    raise PathError::PathError(
      start~,
      message="Unix path: empty path component not allowed",
    )
  }
  guard s.get_char(0) != Some('-') else {
    raise PathError::PathError(
      start~,
      message="Unix path: component '\{s}' cannot start with '-' (not portable according to POSIX standard)",
    )
  }
  for i, ch in s {
    guard ch != '/' else {
      raise PathError::PathError(
        start=start + i,
        message="Unix path: forward slash '/' at position \{start + i} not allowed in path component",
      )
    }
    guard ch != '\u0000' else {
      raise PathError::PathError(
        start=start + i,
        message="Unix path: null character (\\u0000) at position \{start + i} not allowed in path component",
      )
    }
  }
  UnixPathComponent(s.to_string())
}

///|
pub impl PlatformPath for WinPathComponent with from(s) {
  WinPathComponent::from(s)
}

///|
pub impl PlatformPath for UnixPathComponent with from(s) {
  guard !s.is_empty() else {
    raise PathError::PathError(
      start=0,
      message="Unix path: empty path component not allowed",
    )
  }
  guard s.get_char(0) != Some('-') else {
    raise PathError::PathError(
      start=0,
      message="Unix path: component '\{s}' cannot start with '-' (not portable according to POSIX standard)",
    )
  }
  for i, ch in s {
    guard ch != '/' else {
      raise PathError::PathError(
        start=i,
        message="Unix path: forward slash '/' at position \{i} not allowed in path component",
      )
    }
    guard ch != '\u0000' else {
      raise PathError::PathError(
        start=i,
        message="Unix path: null character (\\u0000) at position \{i} not allowed in path component",
      )
    }
  }
  UnixPathComponent(s.to_string())
}

///|
pub(all) suberror PathError {
  PathError(start~ : Int, message~ : String)
} derive(Show)

///|
pub fn WinPath::is_absolute(self : WinPath) -> Bool {
  self.prefix is Some(_)
}

///|
pub fn WinPath::is_relative(self : WinPath) -> Bool {
  self.prefix is None
}

///|
pub fn UnixPath::is_absolute(self : UnixPath) -> Bool {
  self.is_absolute
}

///|
pub fn UnixPath::is_relative(self : UnixPath) -> Bool {
  !self.is_absolute
}

///|
pub fn Path::is_absolute(self : Path) -> Bool {
  match self {
    UPath(path) => path.is_absolute()
    WPath(path) => path.is_absolute()
  }
}

///|
pub fn Path::is_relative(self : Path) -> Bool {
  match self {
    UPath(path) => path.is_relative()
    WPath(path) => path.is_relative()
  }
}
