///|
/// Parse a Windows path string into WinPath
/// Format: "C:\path\to\file.ext" or "C:\path\to\"
pub fn WinPath::parse(s : StringView) -> WinPath raise {
  if s.length() < 2 {
    raise Failure("Invalid Windows path: too short")
  }

  // Extract drive letter
  let drive = s.get_char(0).unwrap()
  if s.get_char(1).unwrap() != ':' {
    raise Failure("Invalid Windows path: missing colon after drive letter")
  }

  // Handle the remaining path after "C:"
  let remaining = if s.length() > 2 { s[2:].to_string() } else { "" }

  // If remaining starts with \, remove it
  let path_part = if remaining.has_prefix("\\") && remaining.length() > 1 {
    remaining[1:].to_string()
  } else if remaining == "\\" {
    "" // Just the root directory
  } else if remaining.is_empty() {
    "" // Just drive letter like "C:"
  } else {
    remaining // Relative path like "C:file.txt"
  }

  // Split by backslash
  let parts = if path_part.is_empty() {
    []
  } else {
    split_path(path_part, '\\')
  }

  // Determine if last part is a file
  let (dir_parts, file_opt) = if parts.is_empty() {
    ([], None)
  } else {
    let last_part = parts[parts.length() - 1]
    if has_file_extension(last_part) || is_likely_filename(last_part) {
      // Last part is likely a file
      let dir_parts_array = Array::new()
      for i = 0; i < parts.length() - 1; i = i + 1 {
        dir_parts_array.push(parts[i])
      }
      let (base, ext) = split_filename(last_part)
      let file = File::{ base: WinPathComponent::from(base), extension: ext }
      (dir_parts_array, Some(file))
    } else {
      // All parts are directories
      (parts, None)
    }
  }

  // Create directory components
  let dir_components = dir_parts.map(WinPathComponent::from)
  let directory = Directory(FixedArray::from_array(dir_components))
  match file_opt {
    Some(file) => WinPath::from(disk=drive, directory~, file~)
    None => WinPath::from(disk=drive, directory~)
  }
}

///|
/// 
/// `disk` should be valid drive letter (A-Z, a-z)
///
pub fn WinPath::from(
  disk~ : Char,
  directory~ : WinDirectory,
  file? : WinFile,
) -> WinPath raise {
  // Check precondition: disk must be a valid drive letter
  if not(is_valid_drive_letter(disk)) {
    raise Failure("Invalid drive letter: \{disk}. Must be A-Z or a-z")
  }
  WinPath::{ disk, directory, file }
}

///|
/// Check if a character is a valid Windows drive letter (A-Z, a-z)
fn is_valid_drive_letter(c : Char) -> Bool {
  (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
}

///|
test "WinPath::from with valid drive letters" {
  let dir = Directory([])

  // Test valid uppercase drive letters
  let path_a = WinPath::from(disk='A', directory=dir)
  inspect(path_a.disk, content="A")
  let path_z = WinPath::from(disk='Z', directory=dir)
  inspect(path_z.disk, content="Z")

  // Test valid lowercase drive letters
  let path_a_lower = WinPath::from(disk='a', directory=dir)
  inspect(path_a_lower.disk, content="a")
  let path_z_lower = WinPath::from(disk='z', directory=dir)
  inspect(path_z_lower.disk, content="z")
}

///|
test "WinPath::from with invalid drive letters" {
  let dir = Directory([])

  // Test invalid characters - they should all return Err
  let invalid_chars = ['1', '@', '[', '`', '{', ' ']
  for char in invalid_chars {
    let result = try? WinPath::from(disk=char, directory=dir)
    match result {
      Ok(_) => fail("Expected error for invalid drive letter: \{char}")
      Err(_) => () // Expected behavior
    }
  }
}

///|
test "WinPath::from error messages" {
  let dir = Directory([])

  // Test that error messages are descriptive
  let result = try? WinPath::from(disk='1', directory=dir)
  match result {
    Ok(_) => fail("Expected error for invalid drive letter")
    Err(error) => {
      let error_msg = error.to_string()
      inspect(error_msg.contains("Invalid drive letter"), content="true")
      inspect(error_msg.contains("1"), content="true")
    }
  }
}

///|
pub impl Show for WinPath with output(self, logger) {
  // Format: C:\path\to\file.ext or C:\path\to\ (if no file)
  logger.write_char(self.disk)
  logger.write_string(":\\")

  // Write directory components separated by backslashes
  for i = 0; i < self.directory.length(); i = i + 1 {
    if i > 0 {
      logger.write_char('\\')
    }
    self.directory[i].output(logger)
  }

  // Add file if present
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

///|
test "WinPath Show implementation" {
  // Test empty directory with just drive letter
  let empty_dir = Directory([])
  let path1 = WinPath::from(disk='C', directory=empty_dir)
  inspect(path1.to_string(), content="C:\\")

  // Test with directory components
  let dir_components = ["Users", "John", "Documents"].map(fn(s) {
    WinPathComponent(s)
  })
  let dir = Directory(FixedArray::from_array(dir_components))
  let path2 = WinPath::from(disk='D', directory=dir)
  inspect(path2.to_string(), content="D:\\Users\\John\\Documents")

  // Test with file (no extension)
  let file_base = WinPathComponent("readme")
  let file = File::{ base: file_base, extension: "" }
  let path3 = WinPath::from(disk='E', directory=dir, file~)
  inspect(path3.to_string(), content="E:\\Users\\John\\Documents\\readme")

  // Test with file and extension
  let file_with_ext = File::{ base: file_base, extension: "txt" }
  let path4 = WinPath::from(disk='F', directory=dir, file=file_with_ext)
  inspect(path4.to_string(), content="F:\\Users\\John\\Documents\\readme.txt")

  // Test file in root directory
  let path5 = WinPath::from(disk='G', directory=empty_dir, file=file_with_ext)
  inspect(path5.to_string(), content="G:\\readme.txt")
}

///|
test "WinPath::parse functionality" {
  // Test basic Windows path with drive letter
  let path1 = WinPath::parse("C:")
  inspect(path1.disk, content="C")
  inspect(path1.directory.length(), content="0")
  inspect(path1.file, content="None")

  // Test Windows path with directory
  let path2 = WinPath::parse("D:\\Users\\John")
  inspect(path2.disk, content="D")
  inspect(path2.directory.length(), content="2")
  inspect(path2.directory[0].0, content="Users")
  inspect(path2.directory[1].0, content="John")
  inspect(path2.file, content="None")

  // Test Windows path with file
  let path3 = WinPath::parse("E:\\Documents\\readme.txt")
  inspect(path3.disk, content="E")
  inspect(path3.directory.length(), content="1")
  inspect(path3.directory[0].0, content="Documents")
  match path3.file {
    Some(file) => {
      inspect(file.base.0, content="readme")
      inspect(file.extension, content="txt")
    }
    None => fail("Expected file")
  }

  // Test Windows path with file at root
  let path4 = WinPath::parse("F:\\config.json")
  inspect(path4.disk, content="F")
  inspect(path4.directory.length(), content="0")
  match path4.file {
    Some(file) => {
      inspect(file.base.0, content="config")
      inspect(file.extension, content="json")
    }
    None => fail("Expected file")
  }
}
