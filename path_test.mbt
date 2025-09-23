///|
/// Black-box tests for Path enum type
test "Path::parse Windows paths" {
  // Test basic Windows path with drive letter
  let path1 = @path.Path::parse("C:")
  match path1 {
    @path.WPath(win_path) => {
      inspect(win_path.disk, content="C")
      inspect(win_path.directory.length(), content="0")
      inspect(win_path.file, content="None")
    }
    _ => fail("Expected Windows path")
  }

  // Test Windows path with directory
  let path2 = @path.Path::parse("D:\\Users\\John")
  match path2 {
    @path.WPath(win_path) => {
      inspect(win_path.disk, content="D")
      inspect(win_path.directory.length(), content="2")
      inspect(win_path.directory[0].to_string(), content="Users")
      inspect(win_path.directory[1].to_string(), content="John")
      inspect(win_path.file, content="None")
    }
    _ => fail("Expected Windows path")
  }

  // Test Windows path with file
  let path3 = @path.Path::parse("E:\\Documents\\readme.txt")
  match path3 {
    @path.WPath(win_path) => {
      inspect(win_path.disk, content="E")
      inspect(win_path.directory.length(), content="1")
      inspect(win_path.directory[0].to_string(), content="Documents")
      match win_path.file {
        Some(file) => {
          inspect(file.base.to_string(), content="readme")
          inspect(file.extension, content="txt")
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
  let path1 = @path.Path::parse("/")
  match path1 {
    @path.UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="0")
      match unix_path.file {
        Some(_) => fail("Expected no file")
        None => () // Expected
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test Unix path with directory
  let path2 = @path.Path::parse("/home/user/documents")
  match path2 {
    @path.UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="3")
      match unix_path.file {
        Some(_) => fail("Expected no file")
        None => () // Expected
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test Unix path with file
  let path3 = @path.Path::parse("/etc/config/settings.conf")
  match path3 {
    @path.UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="2")
      match unix_path.file {
        Some(file) => inspect(file.extension, content="conf")
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test relative Unix path
  let path4 = @path.Path::parse("relative/path/file.txt")
  match path4 {
    @path.UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="2")
      match unix_path.file {
        Some(file) => inspect(file.extension, content="txt")
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Unix path")
  }
}

///|
test "panic Path::parse empty string" {
  ignore(@path.Path::parse(""))
}

///|
test "Path Show implementation" {
  // Test Windows path string representation
  let win_path = @path.Path::parse("C:\\Users\\John\\document.pdf")
  inspect(win_path.to_string(), content="C:\\Users\\John\\document.pdf")

  // Test Unix path string representation
  let unix_path = @path.Path::parse("/home/user/script.sh")
  inspect(unix_path.to_string(), content="/home/user/script.sh")

  // Test root paths
  let win_root = @path.Path::parse("D:")
  inspect(win_root.to_string(), content="D:\\")
  let unix_root = @path.Path::parse("/")
  inspect(unix_root.to_string(), content="/")
}

///|
test "Path edge cases" {
  // Test path without file extension - treated as directory
  let path1 = @path.Path::parse("/usr/bin/node")
  match path1 {
    @path.UPath(unix_path) => {
      inspect(unix_path.directory.length(), content="3")
      match unix_path.file {
        Some(_) => fail("Expected no file")
        None => () // Expected 
      }
    }
    _ => fail("Expected Unix path")
  }

  // Test Windows path with spaces
  let path2 = @path.Path::parse("C:\\Program Files\\My App\\app.exe")
  match path2 {
    @path.WPath(win_path) => {
      inspect(win_path.directory.length(), content="2")
      match win_path.file {
        Some(file) => inspect(file.extension, content="exe")
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Windows path")
  }
}

///|
test "Path equality and hashing" {
  let path1 = @path.Path::parse("/home/user/file.txt")
  let path2 = @path.Path::parse("/home/user/file.txt")
  let path3 = @path.Path::parse("/home/user/other.txt")
  inspect(path1 == path2, content="true")
  inspect(path1 == path3, content="false")
  let win_path1 = @path.Path::parse("C:\\Users\\John\\doc.pdf")
  let win_path2 = @path.Path::parse("C:\\Users\\John\\doc.pdf")
  inspect(win_path1 == win_path2, content="true")
}

///|
test "Path JSON serialization" {
  let path = @path.Path::parse("/home/user/config.json")
  let _path_json = path.to_json()
  // Test that the JSON conversion succeeds without error
  inspect(path.to_json().stringify().length() > 0, content="true")
}
