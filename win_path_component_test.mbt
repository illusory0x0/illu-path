///|
/// Black-box tests for WindowsPathComponent type
/// Since WindowsPathComponent is opaque, we test it through Directory[WindowsPathComponent] and WinPath
test "WindowsPathComponent through Directory creation" {
  // Test valid Windows path components
  let valid_components : Array[String] = ["Users", "John", "Documents"]
  let win_dir : @path.WinDirectory = @path.Directory::from_array(
    valid_components,
  )
  inspect(win_dir.length(), content="3")
}

///|
test "WindowsPathComponent through Directory iteration" {
  let components : Array[String] = ["Program Files", "MyApp"]
  let win_dir : @path.WinDirectory = @path.Directory::from_array(components)
  let mut count = 0
  for _component in win_dir.iter() {
    count += 1
  }
  inspect(count, content="2")
}

///|
test "panic WindowsPathComponent with invalid components" {
  // Test invalid Windows path components (reserved names)
  let invalid_components : Array[String] = ["CON", "valid"]
  // This should abort since from_array uses abort() for invalid components
  ignore((@path.Directory::from_array(invalid_components) : @path.WinDirectory))
}

///|
test "WindowsPathComponent through WinPath parsing" {
  // Test that Windows path components work correctly through WinPath
  let win_path = @path.WinPath::parse("C:\\Users\\Administrator\\Desktop")
  inspect(win_path.disk, content="C")
  inspect(win_path.directory.length(), content="3")

  // Test path with reserved names should fail
  let result = try? @path.WinPath::parse("C:\\CON\\file.txt")
  match result {
    Ok(_) => fail("Expected error for reserved name")
    Err(_) => () // Expected
  }
}

///|
test "WindowsPathComponent equality and hashing" {
  let components1 : Array[String] = ["Windows", "System32"]
  let components2 : Array[String] = ["Windows", "System32"]
  let components3 : Array[String] = ["Windows", "System"]
  let dir1 : @path.WinDirectory = @path.Directory::from_array(components1)
  let dir2 : @path.WinDirectory = @path.Directory::from_array(components2)
  let dir3 : @path.WinDirectory = @path.Directory::from_array(components3)
  inspect(dir1 == dir2, content="true")
  inspect(dir1 == dir3, content="false")
}

///|
test "WindowsPathComponent JSON serialization" {
  let win_dir : @path.WinDirectory = @path.Directory::from_array([
    "Users", "John",
  ])

  // Test that JSON serialization works for directories with WindowsPathComponent
  let _json = win_dir.to_json()
  inspect(win_dir.to_json().stringify().length() > 0, content="true")
}
