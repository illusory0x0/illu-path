///|
/// PlatformPath trait implementation for UnixPathComponent
/// Provides validation and creation functionality for Unix path components
pub impl PlatformPath for UnixPathComponent with from(s) {
  if not(UnixPathComponent::is_system_call_valid(s)) {
    raise Failure("Invalid Unix path component: \{s}")
  }
  UnixPathComponent(s)
}

///|
/// 1. `\0` null character is not allowed
/// 2. `/` forward slash is not allowed
/// 3. Component cannot be empty
pub impl PlatformPath for UnixPathComponent with is_system_call_valid(s) {
  if s.is_empty() {
    return false
  }
  for i = 0; i < s.length(); i = i + 1 {
    let char_code = s[i]
    if char_code == 0 || char_code == '/'.to_int() {
      return false
    }
  }
  true
}

///|
test "UnixPathComponent::is_valid valid cases" {
  assert_eq(UnixPathComponent::is_system_call_valid("hello"), true)
  assert_eq(UnixPathComponent::is_system_call_valid("world.txt"), true)
  assert_eq(UnixPathComponent::is_system_call_valid("my-file"), true)
  assert_eq(UnixPathComponent::is_system_call_valid("123"), true)
  assert_eq(UnixPathComponent::is_system_call_valid("file with spaces"), true)
  assert_eq(UnixPathComponent::is_system_call_valid("."), true)
  assert_eq(UnixPathComponent::is_system_call_valid(".."), true)
}

///|
test "UnixPathComponent::is_valid invalid cases" {
  assert_eq(UnixPathComponent::is_system_call_valid(""), false)
  assert_eq(UnixPathComponent::is_system_call_valid("file/with/slash"), false)
  // Note: Testing null byte would require special handling
}

///|
test "UnixPathComponent::from valid case" {
  let component = UnixPathComponent::from("valid-name")
  // Test passes if no exception is raised
  assert_eq(true, true)
}

///|
test "panic UnixPathComponent::from invalid case" {
  ignore(UnixPathComponent::from(""))
}

///|
pub impl Show for UnixPathComponent with output(self, logger) {
  logger.write_string(self.0)
}
