///|
pub impl Show for WinPathComponent with output(self, logger) {
  logger.write_string(self.0)
}

///|
pub impl Show for WinPathComponent with to_string(self) = "%identity"

///|
pub impl Show for UnixPathComponent with output(self, logger) {
  logger.write_object(self.0)
}

///|
pub impl Show for UnixPathComponent with to_string(self) = "%identity"
