///|
/// Black-box tests for UnixPathComponent type
/// Since UnixPathComponent is opaque, we test it through Directory[UnixPathComponent] and UnixPath
test "UnixPathComponent through Directory creation" {
  // Test valid Unix path components
  let valid_components : Array[String] = ["home", "user", "documents"]
  let unix_dir : @path.UnixDirectory = @path.Directory::from_array(
    valid_components,
  )
  inspect(unix_dir.length(), content="3")
}

///|
test "UnixPathComponent through Directory iteration" {
  let components : Array[String] = ["usr", "local", "bin"]
  let unix_dir : @path.UnixDirectory = @path.Directory::from_array(components)
  let mut count = 0
  for _component in unix_dir.iter() {
    count += 1
  }
  inspect(count, content="3")
}

///|
test "panic UnixPathComponent with invalid components" {
  // Test invalid Unix path components (empty strings)
  let invalid_components : Array[String] = ["valid", "", "also_valid"]
  // This should abort since from_array uses abort() for invalid components
  ignore(
    (@path.Directory::from_array(invalid_components) : @path.UnixDirectory),
  )
}

///|
test "UnixPathComponent through UnixPath parsing" {
  // Test that Unix path components work correctly through UnixPath
  let unix_path = @path.UnixPath::parse("/home/user/documents")
  inspect(unix_path.directory.length(), content="3")

  // Test absolute and relative paths
  let relative_path = @path.UnixPath::parse("relative/dir/file.txt")
  inspect(relative_path.directory.length(), content="2")
}

///|
test "UnixPathComponent special characters" {
  // Test Unix components with special characters (should work)
  let components_with_special : Array[String] = [
    "home", "user-name", "my_documents",
  ]
  let unix_dir : @path.UnixDirectory = @path.Directory::from_array(
    components_with_special,
  )
  inspect(unix_dir.length(), content="3")
}

///|
test "UnixPathComponent equality and hashing" {
  let components1 : Array[String] = ["usr", "local"]
  let components2 : Array[String] = ["usr", "local"]
  let components3 : Array[String] = ["usr", "bin"]
  let dir1 : @path.UnixDirectory = @path.Directory::from_array(components1)
  let dir2 : @path.UnixDirectory = @path.Directory::from_array(components2)
  let dir3 : @path.UnixDirectory = @path.Directory::from_array(components3)
  inspect(dir1 == dir2, content="true")
  inspect(dir1 == dir3, content="false")
}

///|
test "UnixPathComponent JSON serialization" {
  let unix_dir : @path.UnixDirectory = @path.Directory::from_array([
    "etc", "config",
  ])

  // Test that JSON serialization works for directories with UnixPathComponent
  let _json = unix_dir.to_json()
  inspect(unix_dir.to_json().stringify().length() > 0, content="true")
}
