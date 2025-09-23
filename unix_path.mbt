///|
/// Parse a Unix path string into UnixPath
/// Format: "/path/to/file.ext" or "/path/to/"
pub fn UnixPath::parse(s : StringView) -> UnixPath raise {
  // Handle root path "/"
  if s == "/" {
    return UnixPath::from(directory=Directory([]))
  }

  // Remove leading slash if present
  let path_part = if s.has_prefix("/") {
    s[1:].to_string()
  } else {
    s.to_string() // Relative path
  }

  // Split by forward slash
  let parts = if path_part.is_empty() { [] } else { split_path(path_part, '/') }

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
      let file = File::{ base: UnixPathComponent::from(base), extension: ext }
      (dir_parts_array, Some(file))
    } else {
      // All parts are directories
      (parts, None)
    }
  }

  // Create directory components
  let dir_components = dir_parts.map(UnixPathComponent::from)
  let directory = Directory(FixedArray::from_array(dir_components))
  match file_opt {
    Some(file) => UnixPath::from(directory~, file~)
    None => UnixPath::from(directory~)
  }
}

///|
pub fn UnixPath::from(directory~ : UnixDirectory, file? : UnixFile) -> UnixPath {
  UnixPath::{ directory, file }
}

///|
pub impl Show for UnixPath with output(self, logger) {
  // Format: /path/to/file.ext or /path/to/ (if no file)
  logger.write_char('/')

  // Write directory components separated by forward slashes
  for i = 0; i < self.directory.length(); i = i + 1 {
    if i > 0 {
      logger.write_char('/')
    }
    self.directory[i].output(logger)
  }

  // Add file if present
  match self.file {
    Some(file) => {
      if self.directory.length() > 0 {
        logger.write_char('/')
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
test "UnixPath Show implementation" {
  // Test empty directory (root)
  let empty_dir = Directory([])
  let path1 = UnixPath::from(directory=empty_dir)
  inspect(path1.to_string(), content="/")

  // Test with directory components
  let dir_components = ["home", "john", "documents"].map(fn(s) {
    UnixPathComponent(s)
  })
  let dir = Directory(FixedArray::from_array(dir_components))
  let path2 = UnixPath::from(directory=dir)
  inspect(path2.to_string(), content="/home/john/documents")

  // Test with file (no extension)
  let file_base = UnixPathComponent("readme")
  let file = File::{ base: file_base, extension: "" }
  let path3 = UnixPath::from(directory=dir, file~)
  inspect(path3.to_string(), content="/home/john/documents/readme")

  // Test with file and extension
  let file_with_ext = File::{ base: file_base, extension: "txt" }
  let path4 = UnixPath::from(directory=dir, file=file_with_ext)
  inspect(path4.to_string(), content="/home/john/documents/readme.txt")

  // Test file in root directory
  let path5 = UnixPath::from(directory=empty_dir, file=file_with_ext)
  inspect(path5.to_string(), content="/readme.txt")
}

///|
test "UnixPath::parse functionality" {
  // Test root path
  let path1 = UnixPath::parse("/")
  inspect(path1.directory.length(), content="0")
  inspect(path1.file, content="None")

  // Test Unix path with directory
  let path2 = UnixPath::parse("/home/user/documents")
  inspect(path2.directory.length(), content="3")
  inspect(path2.directory[0].0, content="home")
  inspect(path2.directory[1].0, content="user")
  inspect(path2.directory[2].0, content="documents")
  inspect(path2.file, content="None")

  // Test Unix path with file
  let path3 = UnixPath::parse("/etc/config/settings.conf")
  inspect(path3.directory.length(), content="2")
  inspect(path3.directory[0].0, content="etc")
  inspect(path3.directory[1].0, content="config")
  match path3.file {
    Some(file) => {
      inspect(file.base.0, content="settings")
      inspect(file.extension, content="conf")
    }
    None => fail("Expected file")
  }

  // Test Unix path with file at root
  let path4 = UnixPath::parse("/README.md")
  inspect(path4.directory.length(), content="0")
  match path4.file {
    Some(file) => {
      inspect(file.base.0, content="README")
      inspect(file.extension, content="md")
    }
    None => fail("Expected file")
  }

  // Test relative Unix path
  let path5 = UnixPath::parse("relative/path/file.txt")
  inspect(path5.directory.length(), content="2")
  inspect(path5.directory[0].0, content="relative")
  inspect(path5.directory[1].0, content="path")
  match path5.file {
    Some(file) => {
      inspect(file.base.0, content="file")
      inspect(file.extension, content="txt")
    }
    None => fail("Expected file")
  }
}
