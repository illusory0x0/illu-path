///|
pub struct File[Component] {
  base : Component
  extension : String
} derive(ToJson, Hash, Eq)

///|
struct Directory[Component](FixedArray[Component]) derive(ToJson, Hash, Eq)

///|
pub struct WinPath {
  disk : Char
  directory : WinDirectory
  file : WinFile?
} derive(ToJson, Hash, Eq)

///|
pub struct UnixPath {
  directory : UnixDirectory
  file : UnixFile?
} derive(ToJson, Hash, Eq)

///|
pub(all) enum Path {
  WPath(WinPath)
  UPath(UnixPath)
} derive(ToJson, Hash, Eq)

///|
struct WinPathComponent(String) derive(ToJson, Hash, Eq)

///|
struct UnixPathComponent(String) derive(ToJson, Hash, Eq)

///|
pub typealias Directory[WinPathComponent] as WinDirectory

///|
pub typealias Directory[UnixPathComponent] as UnixDirectory

///|
pub typealias File[WinPathComponent] as WinFile

///|
pub typealias File[UnixPathComponent] as UnixFile

///|
trait PlatformPath {
  from(s : String) -> Self raise
  is_system_call_valid(s : String) -> Bool
}
