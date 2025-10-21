///|
pub fn WinPath::parse(s : StringView) -> WinPath raise {
  if s.length() < 2 {
    raise Failure("Invalid Windows path: too short")
  }
  let drive = s.get_char(0).unwrap()
  if s.get_char(1).unwrap() != ':' {
    raise Failure("Invalid Windows path: missing colon after drive letter")
  }
  let remaining = if s.length() > 2 { s[2:].to_string() } else { "" }
  let path_part = if remaining.has_prefix("\\") && remaining.length() > 1 {
    remaining[1:].to_string()
  } else if remaining == "\\" {
    ""
  } else if remaining.is_empty() {
    ""
  } else {
    remaining
  }
  let parts = if path_part.is_empty() {
    []
  } else {
    split_path(path_part, '\\')
  }
  let (dir_parts, file_opt) = if parts.is_empty() {
    ([], None)
  } else {
    let last_part = parts[parts.length() - 1]
    if has_file_extension(last_part) || is_likely_filename(last_part) {
      let dir_parts_array = Array::new()
      for i = 0; i < parts.length() - 1; i = i + 1 {
        dir_parts_array.push(parts[i])
      }
      let (base, ext) = split_filename(last_part)
      let file = File::{ base: WinPathComponent::from(base), extension: ext }
      (dir_parts_array, Some(file))
    } else {
      (parts, None)
    }
  }
  let dir_components = dir_parts.map(WinPathComponent::from)
  let directory = Directory(FixedArray::from_array(dir_components))
  match file_opt {
    Some(file) => WinPath::from(disk=drive, directory~, file~)
    None => WinPath::from(disk=drive, directory~)
  }
}

///|
pub fn WinPath::from(
  disk~ : Char,
  directory~ : WinDirectory,
  file? : WinFile,
) -> WinPath raise {
  if not(is_valid_drive_letter(disk)) {
    raise Failure("Invalid drive letter: \{disk}. Must be A-Z or a-z")
  }
  WinPath::{ disk, directory, file }
}

///|
fn is_valid_drive_letter(c : Char) -> Bool {
  (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
}

///|
pub impl Show for WinPath with output(self, logger) {
  logger.write_char(self.disk)
  logger.write_string(":\\")
  for i = 0; i < self.directory.length(); i = i + 1 {
    if i > 0 {
      logger.write_char('\\')
    }
    self.directory[i].output(logger)
  }
  match self.file {
    Some(file) => {
      if self.directory.length() > 0 {
        logger.write_char('\\')
      }
      file.base.output(logger)
      if file.extension.length() > 0 {
        logger.write_char('.')
        logger.write_string(file.extension)
      }
    }
    None => ()
  }
}
