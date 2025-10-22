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

///|
pub impl[A : Show] Show for File[A] with output(self, logger) {
  logger.write_object(self.base)
  if !self.extension.is_empty() {
    logger.write_char('.')
    logger.write_string(self.extension)
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
