///|
pub impl[Component : Show] Show for File[Component] with output(self, logger) {
  self.base.output(logger)
  if self.extension.length() > 0 {
    logger.write_char('.')
    logger.write_string(self.extension)
  }
}

///|
pub impl Show for Path with output(self, logger) {
  match self {
    UPath(path) => path.output(logger)
    WPath(path) => path.output(logger)
  }
}

///|
pub impl[T : Show] Show for Directory[T] with output(self, logger) {
  logger.write_char('/')
  let mut first = true
  for component in self.iter() {
    if not(first) {
      logger.write_char('/')
    }
    component.output(logger)
    first = false
  }
}

///|
pub impl Show for UnixPath with output(self, logger) {
  logger.write_char('/')
  for i = 0; i < self.directory.length(); i = i + 1 {
    if i > 0 {
      logger.write_char('/')
    }
    self.directory[i].output(logger)
  }
  match self.file {
    Some(file) => {
      if self.directory.length() > 0 {
        logger.write_char('/')
      }
      file.base.output(logger)
      if file.extension.length() > 0 {
        logger.write_char('.')
        logger.write_string(file.extension)
      }
    }
    None => ()
  }
}

///|
pub impl Show for WinPathComponent with output(self, logger) {
  logger.write_string(self.0)
}

///|
pub impl Show for WinPath with output(self, logger) {
  logger.write_char(self.disk)
  logger.write_string(":\\")
  for i = 0; i < self.directory.length(); i = i + 1 {
    if i > 0 {
      logger.write_char('\\')
    }
    self.directory[i].output(logger)
  }
  match self.file {
    Some(file) => {
      if self.directory.length() > 0 {
        logger.write_char('\\')
      }
      file.base.output(logger)
      if file.extension.length() > 0 {
        logger.write_char('.')
        logger.write_string(file.extension)
      }
    }
    None => ()
  }
}

///|
pub impl Show for UnixPathComponent with output(self, logger) {
  logger.write_string(self.0)
}
