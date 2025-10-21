///|
pub impl Show for Path with output(self, logger) {
  match self {
    UPath(path) => path.output(logger)
    WPath(path) => path.output(logger)
  }
}

///|
pub fn Path::parse(s : StringView) -> Path raise {
  if s.is_empty() {
    raise Failure("Empty path string")
  }
  if is_windows_path(s) {
    WPath(WinPath::parse(s))
  } else {
    UPath(UnixPath::parse(s))
  }
}

///|
fn is_windows_path(s : StringView) -> Bool {
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
