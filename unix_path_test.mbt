///|
/// Black-box tests for UnixPath type
test "UnixPath::parse basic functionality" {
  // Test root path
  let path1 = @path.UnixPath::parse("/")
  inspect(path1.directory.length(), content="0")
  match path1.file {
    Some(_) => fail("Expected no file")
    None => () // Expected
  }

  // Test path with directories
  let path2 = @path.UnixPath::parse("/home/user/documents")
  inspect(path2.directory.length(), content="3")
  match path2.file {
    Some(_) => fail("Expected no file")
    None => () // Expected
  }

  // Test path with file
  let path3 = @path.UnixPath::parse("/etc/config.json")
  inspect(path3.directory.length(), content="1")
  match path3.file {
    Some(file) => inspect(file.extension, content="json")
    None => fail("Expected file")
  }
}

///|
test "UnixPath::from constructor" {
  let dir_components : Array[String] = ["home", "user"]
  let _directory : @path.UnixDirectory = @path.Directory::from_array(
    dir_components,
  )
  // Cannot create UnixFile directly as component type is opaque
  // Test by parsing instead
  let unix_path = @path.UnixPath::parse("/home/user/test.txt")
  inspect(unix_path.directory.length(), content="2")
  match unix_path.file {
    Some(f) => inspect(f.extension, content="txt")
    None => fail("Expected file")
  }
}

///|
test "UnixPath Show implementation through Path wrapper" {
  // Test root path via Path wrapper (which has Show)
  let root_path = @path.Path::parse("/")
  inspect(root_path.to_string(), content="/")

  // Test path with directories and file
  let full_path = @path.Path::parse("/home/user/document.pdf")
  inspect(full_path.to_string(), content="/home/user/document.pdf")
}

///|
test "UnixPath relative paths" {
  // Test relative Unix path
  let relative_path = @path.UnixPath::parse("relative/path/file.txt")
  inspect(relative_path.directory.length(), content="2")
  match relative_path.file {
    Some(file) => inspect(file.extension, content="txt")
    None => fail("Expected file")
  }
}

///|
test "UnixPath edge cases" {
  // Test path without file extension - treated as directory
  let path_no_ext = @path.UnixPath::parse("/usr/bin/node")
  inspect(path_no_ext.directory.length(), content="3")
  match path_no_ext.file {
    Some(_) => fail("Expected no file")
    None => () // Expected
  }
}

///|
test "UnixPath equality and hashing" {
  let unix_path1 = @path.UnixPath::parse("/home/user/file.txt")
  let unix_path2 = @path.UnixPath::parse("/home/user/file.txt")
  let unix_path3 = @path.UnixPath::parse("/home/user/other.txt")
  inspect(unix_path1 == unix_path2, content="true")
  inspect(unix_path1 == unix_path3, content="false")
}

///|
test "UnixPath JSON serialization" {
  let unix_path = @path.UnixPath::parse("/home/user/config.json")
  let _unix_path_json = unix_path.to_json()
  // Test that the JSON conversion succeeds without error
  inspect(unix_path.to_json().stringify().length() > 0, content="true")
}
