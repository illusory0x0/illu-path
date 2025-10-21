///|
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
pub impl Show for UnixPathComponent with output(self, logger) {
  logger.write_string(self.0)
}
