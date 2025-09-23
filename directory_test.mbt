///|
/// Black-box tests for Directory[Component] type
/// Tests for UnixDirectory (Directory[UnixPathComponent])
test "UnixDirectory basic functionality" {
  let components : Array[String] = ["home", "user", "documents"]
  let dir : @path.UnixDirectory = @path.Directory::from_array(components)
  inspect(dir.length(), content="3")
  // Components are opaque types, can't inspect directly but can check count
}

///|
test "UnixDirectory empty directory" {
  let empty_components : Array[String] = []
  let dir : @path.UnixDirectory = @path.Directory::from_array(empty_components)
  inspect(dir.length(), content="0")
}

///|
test "UnixDirectory iteration" {
  let components : Array[String] = ["usr", "local", "bin"]
  let dir : @path.UnixDirectory = @path.Directory::from_array(components)
  let mut count = 0
  for _component in dir.iter() {
    count += 1
  }
  inspect(count, content="3")
}

///|
test "panic UnixDirectory with invalid components" {
  let invalid_components : Array[String] = ["valid", "", "also_valid"]
  let result = try? (
      @path.Directory::from_array(invalid_components) : @path.UnixDirectory)
  match result {
    Ok(_) => fail("Expected error for invalid components")
    Err(_) => () // Expected
  }
}

///|
/// Tests for WinDirectory (Directory[WindowsPathComponent])
test "WinDirectory basic functionality" {
  let components : Array[String] = ["Users", "John", "Documents"]
  let dir : @path.WinDirectory = @path.Directory::from_array(components)
  inspect(dir.length(), content="3")
}

///|
test "WinDirectory empty directory" {
  let empty_components : Array[String] = []
  let dir : @path.WinDirectory = @path.Directory::from_array(empty_components)
  inspect(dir.length(), content="0")
}

///|
test "panic WinDirectory with invalid components" {
  let invalid_components : Array[String] = ["CON", "valid"]
  let result = try? (
      @path.Directory::from_array(invalid_components) : @path.WinDirectory)
  match result {
    Ok(_) => fail("Expected error for invalid components")
    Err(_) => () // Expected
  }
}

///|
test "Directory equality and hashing" {
  let components1 : Array[String] = ["home", "user"]
  let components2 : Array[String] = ["home", "user"]
  let components3 : Array[String] = ["home", "other"]
  let dir1 : @path.UnixDirectory = @path.Directory::from_array(components1)
  let dir2 : @path.UnixDirectory = @path.Directory::from_array(components2)
  let dir3 : @path.UnixDirectory = @path.Directory::from_array(components3)
  inspect(dir1 == dir2, content="true")
  inspect(dir1 == dir3, content="false")
}

///|
test "Directory JSON serialization" {
  let unix_dir : @path.UnixDirectory = @path.Directory::from_array([
    "etc", "config",
  ])
  let win_dir : @path.WinDirectory = @path.Directory::from_array([
    "Users", "John",
  ])

  // These should not fail (basic ToJson implementation check)
  // Cannot test exact content since component types are opaque
  // But can verify serialization succeeds
  let _unix_dir_json = unix_dir.to_json()
  let _win_dir_json = win_dir.to_json()

  // Test that the JSON conversion succeeds without error
  inspect(unix_dir.to_json().stringify().length() > 0, content="true")
  inspect(win_dir.to_json().stringify().length() > 0, content="true")
}
