///|
fn parse_windows_relative_path(
  s : StringView,
  start~ : Int,
  root_eliminate~ : Bool,
) -> (WinDirectory, WinFile?) raise PathError {
  let mut rest = s
  let directory : Array[WinPathComponent] = []
  let mut start = start
  let file : WinFile? = for {
    lexmatch rest with longest {
      ((("[^\\]+" as s) "\\") as all, r) => {
        match s {
          "." => ()
          ".." =>
            match (directory.pop(), root_eliminate) {
              (Some(WinPathComponent("..")), _) => {
                directory.push(WinPathComponent(".."))
                directory.push(WinPathComponent(".."))
              }
              (None, true) => ()
              (None, false) => directory.push(WinPathComponent(".."))
              (Some(_), _) => ()
            }
          _ => directory.push(WinPathComponent::from(s, start~))
        }
        start += all.char_length()
        rest = r
      }
      "\.\." => {
        match (directory.pop(), root_eliminate) {
          (Some(WinPathComponent("..")), _) => {
            directory.push(WinPathComponent(".."))
            directory.push(WinPathComponent(".."))
          }
          (None, true) => ()
          (None, false) => directory.push(WinPathComponent(".."))
          (Some(_), _) => ()
        }
        break None
      }
      "\." => break None
      (("[^\\]+" as base) "\." ("[^.\\]+" as extension)) =>
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
  root_eliminate~ : Bool,
) -> (UnixDirectory, UnixFile?) raise PathError {
  let mut rest = s
  let directory : Array[UnixPathComponent] = []
  let mut start = start
  let file : UnixFile? = for {
    lexmatch rest with longest {
      ((("[^/]+" as s) "/") as all, r) => {
        match s {
          "." => ()
          ".." =>
            match (directory.pop(), root_eliminate) {
              (Some(UnixPathComponent("..")), _) => {
                directory.push(UnixPathComponent(".."))
                directory.push(UnixPathComponent(".."))
              }
              (None, true) => ()
              (None, false) => directory.push(UnixPathComponent(".."))
              (Some(_), _) => ()
            }
          _ => directory.push(UnixPathComponent::from(s, start~))
        }
        start += all.char_length()
        rest = r
      }
      "\.\." => {
        match (directory.pop(), root_eliminate) {
          (Some(UnixPathComponent("..")), _) => {
            directory.push(UnixPathComponent(".."))
            directory.push(UnixPathComponent(".."))
          }
          (None, true) => ()
          (None, false) => directory.push(UnixPathComponent(".."))
          (Some(_), _) => ()
        }
        break None
      }
      "\." => break None
      (("[^/.]+" as base) "\." ("[^/]+" as extension)) =>
        break Some(UnixFile::new(base~, extension~))
      ("[^/.]+" as base) => break Some(UnixFile::new(base~))
      "$" => break None
      _ => raise PathError(start~, message="Invalid Unix path")
    }
  }
  (Directory(FixedArray::from_array(directory)), file)
}

///|
fn win_path(
  prefix? : WinPrefix,
  directory? : WinDirectory = [],
  file? : WinFile,
) -> Path {
  WPath(WinPath::{ prefix, directory, file })
}

///|
pub fn Path::parse(s : String) -> Path raise PathError {
  lexmatch s with longest {
    /// without  rest cases 
    ("\\\\\?\\" ("[^\\]+" as symlink)) =>
      win_path(prefix=VerbatimSymlink(symlink=symlink.to_string()))
    ("\\\\\?UNC\\" ("[^\\]+" as hostname) "\\" ("[^\\]+" as shared_folder)) =>
      win_path(
        prefix=VerbatimUNC(
          hostname=hostname.to_string(),
          shared_folder=shared_folder.to_string(),
        ),
      )
    ("\\\\" ("[^\\]+" as hostname) "\\" ("[^\\]+" as shared_folder)) =>
      win_path(
        prefix=UNC(
          hostname=hostname.to_string(),
          shared_folder=shared_folder.to_string(),
        ),
      )
    ("\\\\\.\\" ("[^\\]+" as device)) =>
      win_path(prefix=DeviceNS(device=device.to_string()))
    ("\\\\\?\\" ("[a-zA-Z]" as letter) ":\\") =>
      win_path(prefix=VerbatimVolumeLetter(letter))
    (("[a-zA-Z]" as letter) ":\\") => win_path(prefix=VolumeLetter(letter))
    ("\\\\\?\\" "\\|\.\.|\.") =>
      raise PathError(
        start=0,
        message="Invalid Windows path: Verbatim prefix can use for relative path",
      )
    ("\\\\\?\\Volume[{]" ("[^}]+" as guid) "[}]") =>
      win_path(prefix=VerbatimVolumeGUID(guid.to_string()))
    ("\\\\\?UNC\\" ("[^\\]+" as hostname) "\\" ("[^\\]+" as shared_folder) "\\") =>
      win_path(
        prefix=VerbatimUNC(
          hostname=hostname.to_string(),
          shared_folder=shared_folder.to_string(),
        ),
      )

    // with rest cases 

    (("\\\\\?\\" ("[^\\]+" as symlink) "\\") as prefix, rest) => {

      // TODO: check symlink name 
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(
        prefix=VerbatimSymlink(symlink=symlink.to_string()),
        directory~,
        file?,
      )
    }
    ("\\\\\?\\Volume[{]" ("[^}]+" as guid) "[}]") =>
      win_path(prefix=VerbatimVolumeGUID(guid.to_string()))
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
        root_eliminate=true,
      )
      win_path(
        prefix=VerbatimUNC(
          hostname=hostname.to_string(),
          shared_folder=shared_folder.to_string(),
        ),
        directory~,
        file?,
      )
    }
    (
      ("\\\\" ("[^\\]+" as hostname) "\\" ("[^\\]+" as shared_folder) "\\") as prefix,
      rest
    ) => {
      // TODO: check hostname and shared_folder
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(
        prefix=UNC(
          hostname=hostname.to_string(),
          shared_folder=shared_folder.to_string(),
        ),
        directory~,
        file?,
      )
    }
    (("\\\\\?\\Volume[{]" ("[^}]+" as guid) "[}]") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(prefix=VerbatimVolumeGUID(guid.to_string()), directory~, file?)
    }
    (("\\\\\.\\" ("[^\\]+" as device) "\\") as prefix, rest) => {
      // check the device 
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(prefix=DeviceNS(device=device.to_string()), directory~, file?)
    }
    (("\\\\\?\\" ("[a-zA-Z]" as letter) ":\\") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(prefix=VerbatimVolumeLetter(letter), directory~, file?)
    }
    ("\\\\\?\\" "\\|\.\.|\.", _) =>
      raise PathError(
        start=0,
        message="Invalid Windows path: Verbatim prefix can use for relative path",
      )
    ((("[a-zA-Z]" as letter) ":\\") as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=true,
      )
      win_path(prefix=VolumeLetter(letter), directory~, file?)
    }
    // current path 
    ("\.\\" as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=false,
      )
      win_path(directory~, file?)
    }
    // current path 
    ("\./" as prefix, rest) => {
      let (directory, file) = parse_unix_relative_path(
        rest,
        start=prefix.char_length(),
        root_eliminate=false,
      )
      UPath(UnixPath::new(directory~, file?))
    }

    // root path but without derive letter 
    ("\\" as prefix, rest) => {
      let (directory, file) = parse_windows_relative_path(
        rest,
        start=prefix.utf16_len(),
        root_eliminate=true,
      )
      win_path(prefix=Root, directory~, file?)
    }

    // root path 
    ("/" as prefix, rest) => {
      let (directory, file) = parse_unix_relative_path(
        rest,
        start=prefix.utf16_len(),
        root_eliminate=true,
      )
      UPath(UnixPath::new(is_absolute=true, directory~, file?))
    }
    _ => raise PathError(start=0, message="Invalid path format")
  }
}

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
fn WinPathComponent::from(
  s : StringView,
  start~ : Int,
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
fn UnixPathComponent::from(
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
