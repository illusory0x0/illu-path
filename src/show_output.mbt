///|
pub impl Show for WinPathComponent with output(self, logger) {
  logger.write_string(self.0)
}

///|
pub impl Show for WinPathComponent with to_string(self) = "%identity"

///|
pub impl Show for UnixPathComponent with output(self, logger) {
  logger.write_string(self.0)
}

///|
pub impl Show for UnixPathComponent with to_string(self) = "%identity"

///|
impl IsEmpty for WinPathComponent with is_empty(self) {
  self.0 == ""
}

///|
impl IsEmpty for UnixPathComponent with is_empty(self) {
  self.0 == ""
}

///|
trait IsEmpty {
  is_empty(Self) -> Bool
}

///|
pub impl[A : Show + IsEmpty] Show for File[A] with output(self, logger) {
  logger.write_object(self.base)
  if !self.extension.is_empty() {
    logger.write_char('.')
    logger.write_object(self.extension)
  }
}

///|
const VerbatimPrefix : String =
  #|\\?\

///|
const VerbatimUncPrefix : String =
  #|\\?\UNC\

///|
const ColonBackslash : String =
  #|:\

///|
const VolumePrefix : String =
  #|\\?\Volume{

///|
const VolumeSuffix : String =
  #|}:\

///|
const DevicePrefix : String =
  #|\\.\

///|
const UncPrefix : String =
  #|\\

///|
const BackSlash : Char = '\\'

///|
pub impl Show for WinPrefix with output(self, logger) {
  match self {
    Verbatim(symlink~) => {
      logger.write_string(VerbatimPrefix)
      logger.write_string(symlink)
    }
    VerbatimUNC(hostname~, shared_folder~) => {
      logger.write_string(VerbatimUncPrefix)
      logger.write_string(hostname)
      logger.write_char(BackSlash)
      logger.write_string(shared_folder)
    }
    VerbatimVolumeLetter(letter) => {
      logger.write_string(VerbatimPrefix)
      logger.write_char(letter)
      logger.write_string(ColonBackslash)
    }
    VerbatimVolumeGUID(guid) => {
      logger.write_string(VolumePrefix)
      logger.write_string(guid)
      logger.write_string(VolumeSuffix)
    }
    DeviceNS(device~) => {
      logger.write_string(DevicePrefix)
      logger.write_string(device)
    }
    UNC(hostname~, shared_folder~) => {
      logger.write_string(UncPrefix)
      logger.write_string(hostname)
      logger.write_char(BackSlash)
      logger.write_string(shared_folder)
    }
    VolumeLetter(letter) => {
      logger.write_char(letter)
      logger.write_string(ColonBackslash)
    }
  }
}

///|
pub impl Show for WinPath with output(self, logger) {
  let { prefix, directory, file } = self
  if prefix is Some(prefix) {
    logger.write_object(prefix)
  }
  loop directory[:] {
    [] => ()
    [x, .. xs] => {
      logger.write_object(x)
      logger.write_char(BackSlash)
      continue xs
    }
  }
  if file is Some(file) {
    logger.write_object(file)
  }
}

///|
const Slash = '/'

///|
pub impl Show for UnixPath with output(self, logger) {
  let { is_absolute, directory, file } = self
  if is_absolute {
    logger.write_char(Slash)
  }
  loop directory[:] {
    [] => ()
    [x, .. xs] => {
      logger.write_object(x)
      logger.write_char(Slash)
      continue xs
    }
  }
  if file is Some(file) {
    logger.write_object(file)
  }
}

///|
pub impl Show for Path with output(self, logger) {
  match self {
    UPath(path) => logger.write_object(path)
    WPath(path) => logger.write_object(path)
  }
}

///|
test "unix path" {
  let path = UnixPath::new(directory=Directory::new(["username", ".moon"]))
  inspect(path, content="username/.moon/")
  let path = UnixPath::new(
    is_absolute=true,
    directory=Directory::new(["home", "username", ".moon"]),
  )
  inspect(path, content="/home/username/.moon/")
}
