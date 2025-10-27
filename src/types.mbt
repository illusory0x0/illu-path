///|
pub(all) enum Path {
  WPath(WinPath)
  UPath(UnixPath)
} derive(ToJson, Hash, Eq)

///|
/// [Microsoft Naming a Volume](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-volume)
/// [Microsoft Naming Files, Paths, and Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)
/// [Microsoft Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
pub struct WinPath {
  prefix : WinPrefix
  directory : WinDirectory
  file : WinFile?
} derive(ToJson, Hash, Eq)

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
  /// Syntax: `\`
  ///
  /// Example: `\Users\username\Documents\`
  Root
  /// Syntax: `\\?\<SYMLINK>\` 
  ///
  /// Example: `\\?\GLOBALROOT\`
  VerbatimSymlink(symlink~ : String)
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
  None
} derive(ToJson, Hash, Eq)

///|
pub(all) enum UnixPrefix {
  /// Syntax: `/` or `/{3,}`
  ///
  /// A pathname consisting of a single <slash> shall resolve to the root directory of the process.
  Root
  /// Syntax: `//`
  ///
  /// [Posix 4.13 Pathname Resolution](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_13)
  ///
  /// > If a pathname begins with two successive <slash> characters, 
  /// > the first component following the leading <slash> characters may be interpreted in an implementation-defined manner,
  /// > although more than two leading <slash> characters shall be treated as a single <slash> character.
  SlashSlash
  None
} derive(ToJson, Hash, Eq)

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
pub struct File[Component] {
  base : Component
  extension : Component?
} derive(ToJson, Hash, Eq)

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
struct WinPathComponent(String) derive(ToJson, Hash, Eq)

///|
struct UnixPathComponent(String) derive(ToJson, Hash, Eq)

///|
trait PlatformPath {
  from(s : StringView) -> Self raise PathError
}

///|
pub impl PlatformPath for WinPathComponent with from(s) {
  WinPathComponent::from(s, start=0)
}

///|
pub(all) suberror PathError {
  PathError(start~ : Int, message~ : String)
} derive(Show)

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
let windows_reserved_names_set : Set[StringView] = Set::from_iter(
  windows_reserved_names.iter().map(x => x),
)

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
    | '\u0001'..='\u001F' => true
    _ => false
  }
}

///|
struct PathBuilder {
  prefix : WinPrefix?
  is_absolute : Bool
  directory : Array[String]
  mut basename : String?
  mut extension : String?
}

///|
pub fn PathBuilder::from_path(path : Path) -> PathBuilder {
  match path {
    UPath(path) => {
      let prefix = Option::None
      let is_absolute = path.is_absolute()
      let directory = path.directory[:]
        .iter()
        .map(IsString::to_string)
        .collect()
      let mut basename : String? = None
      let mut extension : String? = None
      match path.file {
        Some({ base, extension: Some(UnixPathComponent(ext)) }) => {
          basename = Some(base.0)
          extension = Some(ext)
        }
        Some({ base, extension: None }) => basename = Some(base.0)
        _ => ()
      }
      PathBuilder::{ prefix, is_absolute, directory, basename, extension }
    }
    WPath(path) => {
      let prefix = Some(path.prefix)
      let is_absolute = path.is_absolute()
      let directory = path.directory[:]
        .iter()
        .map(IsString::to_string)
        .collect()
      let mut basename : String? = None
      let mut extension : String? = None
      match path.file {
        Some({ base, extension: Some(WinPathComponent(ext)) }) => {
          basename = Some(base.0)
          extension = Some(ext)
        }
        Some({ base, extension: None }) => basename = Some(base.0)
        _ => ()
      }
      PathBuilder::{ prefix, is_absolute, directory, basename, extension }
    }
  }
}

///|
pub fn PathBuilder::to_path(self : PathBuilder) -> Path {
  match self.prefix {
    Some(prefix) => {
      // windows path
      let components : Array[WinPathComponent] = self.directory[:]
        .iter()
        .map(x => WinPathComponent(x))
        .collect()
      let directory = Directory(FixedArray::from_array(components))
      let file : WinFile? = match self.basename {
        Some(b) => {
          let ext : WinPathComponent? = match self.extension {
            Some(e) => Some(WinPathComponent(e))
            None => None
          }
          Some(File::{ base: WinPathComponent(b), extension: ext })
        }
        None => None
      }
      WPath(WinPath::new(prefix~, directory~, file?))
    }
    None => {
      // unix path
      let components : Array[UnixPathComponent] = self.directory[:]
        .iter()
        .map(x => UnixPathComponent(x))
        .collect()
      let directory = Directory(FixedArray::from_array(components))
      let file : UnixFile? = match self.basename {
        Some(b) => {
          let ext : UnixPathComponent? = match self.extension {
            Some(e) => Some(UnixPathComponent(e))
            None => None
          }
          Some(File::{ base: UnixPathComponent(b), extension: ext })
        }
        None => None
      }
      UPath(UnixPath::new(is_absolute=self.is_absolute, directory~, file?))
    }
  }
}

///|
/// When PathBuilder contains filename add_directory would pop this filename, and then add directory in its parent directory
pub fn PathBuilder::add_directory(
  self : PathBuilder,
  directory : StringView,
) -> Unit raise PathError {
  match self.prefix {
    Some(_) => {
      // windows path
      // If there is a basename (filename) remove it, then push the new directory
      if self.basename is Some(_) {
        self.basename = None
        self.extension = None
      }
      let _comp = WinPathComponent::from(directory, start=0)
      self.directory.push(_comp.0)
    }
    None => {
      // unix path
      if self.basename is Some(_) {
        self.basename = None
        self.extension = None
      }
      let _comp = UnixPathComponent::from(directory, start=0)
      self.directory.push(_comp.0)
    }
  }
}

///|
pub fn PathBuilder::set_basename(
  self : PathBuilder,
  basename : StringView,
) -> Unit raise PathError {
  match self.prefix {
    Some(_) => {
      // windows path
      let comp = WinPathComponent::from(basename, start=0)
      self.basename = Some(comp.0)
    }
    None => {
      // unix path
      let comp = UnixPathComponent::from(basename, start=0)
      self.basename = Some(comp.0)
    }
  }
}

///|
pub fn PathBuilder::set_extension(
  self : PathBuilder,
  extension : StringView,
) -> Unit raise PathError {
  match self.prefix {
    Some(_) => {
      // windows path
      // validate extension (must not contain '.') using WinPathComponent rules
      for i, ch in extension {
        if ch == '.' {
          raise PathError(
            start=i,
            message="Extension must not contain '.' character.",
          )
        }
      }
      let comp = WinPathComponent::from(extension, start=0)
      self.extension = Some(comp.0)
    }
    None => {
      // unix path
      let comp = UnixPathComponent::from(extension, start=0)
      self.extension = Some(comp.0)
    }
  }
}

///|
pub fn PathBuilder::set_file(
  self : PathBuilder,
  base~ : StringView,
  extension~ : StringView,
) -> Unit raise PathError {
  self.set_basename(base)
  self.set_extension(extension)
}
