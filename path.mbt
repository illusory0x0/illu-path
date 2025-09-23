///|
pub impl Show for Path with output(self, logger) {
  match self {
    UPath(path) => path.output(logger)
    WPath(path) => path.output(logger)
  }
}

///|
pub fn Path::parse(s : String) -> Path raise {
  if s.is_empty() {
    raise Failure("Empty path string")
  }

  // Check if it's a Windows path (has drive letter pattern like "C:")
  if is_windows_path(s) {
    WPath(WinPath::parse(s))
  } else {
    UPath(UnixPath::parse(s))
  }
}

///|
/// Check if a path string is a Windows path
/// Windows paths start with a drive letter followed by a colon (e.g., "C:", "D:\\")
fn is_windows_path(s : String) -> Bool {
  if s.length() < 2 {
    return false
  }
  let first_char = s.get_char(0)
  let second_char = s.get_char(1)
  match (first_char, second_char) {
    (Some(c), Some(':')) => (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
    _ => false
  }
}

///|
test "Path::parse Windows paths" {
  // Test basic Windows path with drive letter
  let path1 = Path::parse("C:")
  match path1 {
    WPath(win_path) => {
      inspect(win_path.disk, content="C")
      inspect(win_path.directory.length(), content="0")
      inspect(win_path.file, content="None")
    }
    _ => fail("Expected Windows path")
  }

  // Test Windows path with directory
  let path2 = Path::parse("D:\\Users\\John")
  match path2 {
    WPath(win_path) => {
      inspect(win_path.disk, content="D")
      inspect(win_path.directory.length(), content="2")
      inspect(win_path.directory[0].0, content="Users")
      inspect(win_path.directory[1].0, content="John")
      inspect(win_path.file, content="None")
    }
    _ => fail("Expected Windows path")
  }

  // Test Windows path with file
  let path3 = Path::parse("E:\\Documents\\readme.txt")
  match path3 {
    WPath(win_path) => {
      inspect(win_path.disk, content="E")
      inspect(win_path.directory.length(), content="1")
      inspect(win_path.directory[0].0, content="Documents")
      match win_path.file {
        Some(file) => {
          inspect(file.base.0, content="readme")
          inspect(file.extension, content="txt")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Windows path")
  }

  // Test Windows path with file at root
  let path4 = Path::parse("F:\\config.json")
  match path4 {
    WPath(win_path) => {
      inspect(win_path.disk, content="F")
      inspect(win_path.directory.length(), content="0")
      match win_path.file {
        Some(file) => {
          inspect(file.base.0, content="config")
          inspect(file.extension, content="json")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Windows path")
  }
}

///|
test "Path::parse Unix paths" {
  // Test root path
  let path1 = Path::parse("/")
  match path1 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="0")
      inspect(unix_path.file, content="None")
    }
    _ => fail("Expected Unix path")
  }

  // Test Unix path with directory
  let path2 = Path::parse("/home/user/documents")
  match path2 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="3")
      inspect(unix_path.directory[0].0, content="home")
      inspect(unix_path.directory[1].0, content="user")
      inspect(unix_path.directory[2].0, content="documents")
      inspect(unix_path.file, content="None")
    }
    _ => fail("Expected Unix path")
  }

  // Test Unix path with file
  let path3 = Path::parse("/etc/config/settings.conf")
  match path3 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="2")
      inspect(unix_path.directory[0].0, content="etc")
      inspect(unix_path.directory[1].0, content="config")
      match unix_path.file {
        Some(file) => {
          inspect(file.base.0, content="settings")
          inspect(file.extension, content="conf")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test Unix path with file at root
  let path4 = Path::parse("/README.md")
  match path4 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="0")
      match unix_path.file {
        Some(file) => {
          inspect(file.base.0, content="README")
          inspect(file.extension, content="md")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test relative Unix path
  let path5 = Path::parse("relative/path/file.txt")
  match path5 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="2")
      inspect(unix_path.directory[0].0, content="relative")
      inspect(unix_path.directory[1].0, content="path")
      match unix_path.file {
        Some(file) => {
          inspect(file.base.0, content="file")
          inspect(file.extension, content="txt")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Unix path")
  }
}

///|
test "Path::parse edge cases" {
  // Test empty path - should fail
  let result1 = try? Path::parse("")
  match result1 {
    Err(_) => () // Expected
    Ok(_) => fail("Empty path should fail")
  }

  // Test path without file extension - "node" is treated as directory
  let path2 = Path::parse("/usr/bin/node")
  match path2 {
    UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="3")
      inspect(unix_path.directory[2].0, content="node")
      inspect(unix_path.file, content="None")
    }
    _ => fail("Expected Unix path")
  }

  // Test Windows path with spaces
  let path3 = Path::parse("C:\\Program Files\\My App\\app.exe")
  match path3 {
    WPath(win_path) => {
      inspect(win_path.directory.length(), content="2")
      inspect(win_path.directory[0].0, content="Program Files")
      inspect(win_path.directory[1].0, content="My App")
      match win_path.file {
        Some(file) => {
          inspect(file.base.0, content="app")
          inspect(file.extension, content="exe")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Windows path")
  }
}

///|
test "Path::parse detection logic" {
  // Should detect Windows paths correctly
  inspect(is_windows_path("C:"), content="true")
  inspect(is_windows_path("D:\\"), content="true")
  inspect(is_windows_path("z:\\file.txt"), content="true")

  // Should detect Unix paths correctly
  inspect(is_windows_path("/"), content="false")
  inspect(is_windows_path("/home"), content="false")
  inspect(is_windows_path("relative/path"), content="false")
  inspect(is_windows_path("file.txt"), content="false")
}

///|
test "Path::parse Show implementation" {
  // Test Windows path string representation
  let win_path = Path::parse("C:\\Users\\John\\document.pdf")
  inspect(win_path.to_string(), content="C:\\Users\\John\\document.pdf")

  // Test Unix path string representation
  let unix_path = Path::parse("/home/user/script.sh")
  inspect(unix_path.to_string(), content="/home/user/script.sh")

  // Test root paths
  let win_root = Path::parse("D:")
  inspect(win_root.to_string(), content="D:\\")
  let unix_root = Path::parse("/")
  inspect(unix_root.to_string(), content="/")
}
