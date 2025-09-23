///|
/// Parse a filename string into a File object
/// Splits the filename at the last dot to separate base name and extension
/// Examples:
/// - "readme.txt" -> File { base: "readme", extension: "txt" }
/// - "config" -> File { base: "config", extension: "" }
/// - "archive.tar.gz" -> File { base: "archive.tar", extension: "gz" }
/// - ".hidden" -> File { base: "", extension: "hidden" }
pub fn[Component : PlatformPath] File::parse(
  s : StringView,
) -> File[Component] raise {
  if s.is_empty() {
    raise Failure("Empty filename")
  }
  let (base, ext) = split_filename(s.to_string())
  File::{ base: Component::from(base), extension: ext }
}

///|
pub impl[Component : Show] Show for File[Component] with output(self, logger) {
  self.base.output(logger)
  if self.extension.length() > 0 {
    logger.write_char('.')
    logger.write_string(self.extension)
  }
}
