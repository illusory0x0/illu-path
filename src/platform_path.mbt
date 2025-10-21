///|
/// 1. `<`, `>`, `:`, `"`, `|`, `?`, `*`, `\`, `/` characters are not allowed
/// 2. Component cannot be empty
/// 3. reserved names (CON, PRN, AUX, NUL, COM1-COM9, LPT1-LPT9) are not allowed (case insensitive)
/// 4. Cannot end with space or dot
pub impl PlatformPath for WinPathComponent with is_system_call_valid(s) {
  if s.is_empty() {
    return false
  }
  let last_char = s[s.length() - 1]
  if last_char == ' '.to_int() || last_char == '.'.to_int() {
    return false
  }
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
pub impl PlatformPath for WinPathComponent with from(s) {
  if not(WinPathComponent::is_system_call_valid(s)) {
    raise Failure("Invalid Windows path component: \{s}")
  }
  WinPathComponent(s)
}

///|
pub impl PlatformPath for UnixPathComponent with from(s) {
  if not(UnixPathComponent::is_system_call_valid(s)) {
    raise Failure("Invalid Unix path component: \{s}")
  }
  UnixPathComponent(s)
}
