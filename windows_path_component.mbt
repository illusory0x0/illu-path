///|
/// PlatformPath trait implementation for WindowsPathComponent
/// Provides validation and creation functionality for Windows path components
pub impl PlatformPath for WindowsPathComponent with from(s) {
  if not(WindowsPathComponent::is_system_call_valid(s)) {
    raise Failure("Invalid Windows path component: \{s}")
  }
  WindowsPathComponent(s)
}

///|
/// 1. `<`, `>`, `:`, `"`, `|`, `?`, `*`, `\`, `/` characters are not allowed
/// 2. Component cannot be empty
/// 3. reserved names (CON, PRN, AUX, NUL, COM1-COM9, LPT1-LPT9) are not allowed (case insensitive)
/// 4. Cannot end with space or dot
pub impl PlatformPath for WindowsPathComponent with is_system_call_valid(s) {
  if s.is_empty() {
    return false
  }

  // Check for trailing space or dot
  let last_char = s[s.length() - 1]
  if last_char == ' '.to_int() || last_char == '.'.to_int() {
    return false
  }

  // Check for reserved names (case insensitive)
  let upper = s.to_upper()
  let reserved_names = [
    "CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7",
    "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8",
    "LPT9",
  ]
  for reserved in reserved_names {
    if upper == reserved {
      return false
    }
  }

  // Check for invalid characters (only those mentioned in documentation)
  let invalid_char_codes = [
    '<'.to_int(),
    '>'.to_int(),
    ':'.to_int(),
    '"'.to_int(),
    '|'.to_int(),
    '?'.to_int(),
    '*'.to_int(),
    '\\'.to_int(),
    '/'.to_int(),
  ]
  for i = 0; i < s.length(); i = i + 1 {
    let char_code = s[i]
    for invalid_code in invalid_char_codes {
      if char_code == invalid_code {
        return false
      }
    }
  }
  true
}

///|
test "WindowsPathComponent::is_valid valid cases" {
  assert_eq(WindowsPathComponent::is_system_call_valid("hello"), true)
  assert_eq(WindowsPathComponent::is_system_call_valid("world.txt"), true)
  assert_eq(WindowsPathComponent::is_system_call_valid("my-file"), true)
  assert_eq(WindowsPathComponent::is_system_call_valid("123"), true)
  assert_eq(
    WindowsPathComponent::is_system_call_valid("file with spaces"),
    true,
  )
  assert_eq(WindowsPathComponent::is_system_call_valid("ValidName"), true)
}

///|
test "WindowsPathComponent::is_valid invalid cases" {
  assert_eq(WindowsPathComponent::is_system_call_valid(""), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file<invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file>invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file:invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file\"invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file|invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file?invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file*invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file\\invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file/invalid"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("CON"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("con"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("PRN"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("COM1"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("LPT1"), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file."), false)
  assert_eq(WindowsPathComponent::is_system_call_valid("file "), false)
}

///|
test "WindowsPathComponent::from valid case" {
  let _component = WindowsPathComponent::from("valid-name")
  // Test passes if no exception is raised
  assert_eq(true, true)
}

///|
test "panic WindowsPathComponent::from invalid case" {
  ignore(WindowsPathComponent::from("CON"))
}

///|
pub impl Show for WindowsPathComponent with output(self, logger) {
  logger.write_string(self.0)
}
