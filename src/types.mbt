///|
pub(all) enum Path {
  WPath(WinPath)
  UPath(UnixPath)
} derive(ToJson, Hash, Eq)

///|
/// [Microsoft Naming a Volume](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-volume)
/// [Microsoft Naming Files, Paths, and Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)
/// [Microsoft Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
pub struct WinPath {
  disk : Char
  directory : WinDirectory
  file : WinFile?
} derive(ToJson, Hash, Eq)

///|
/// 
/// #### Verbatim Prefix
/// 
/// refer to [Microsoft Win32 File Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file#win32-file-namespaces)
/// > For file I/O,
/// > the "\\?\" prefix to a path string tells the Windows APIs to disable all string parsing and to send the string that follows it straight to the file system.
/// 
/// #### Windows Encoding 
/// 
/// refer to [Microsoft Path Unicode Normalization](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
/// 
/// > There is no need to perform any Unicode normalization on path and file name strings for use by the Windows file I/O API functions 
/// > because the file system treats path and file names as an opaque sequence of WCHARs.
/// > Any normalization that your application requires should be performed with this in mind, 
/// > external of any calls to related Windows file I/O API functions.
/// 
/// #### Relative Paths Cannot use Verbatim Prefix
/// 
/// refer to [Microsoft Verbatim restriction](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
/// 
/// > Because you cannot use the "\\?\" prefix with a relative path, 
/// > relative paths are always limited to a total of MAX_PATH characters.
/// 
pub(all) enum WinPrefix {
  /// Syntax: `\\?\<SYMLINK>`
  ///
  /// Example: `\\?\GLOBALROOT`
  Verbatim(symlink~ : String)
  /// Syntax: `\\?\UNC\<SERVER>\<SHARE>`
  ///
  /// Example: `\\?\UNC\server\share`
  VerbatimUNC(hostname~ : String, shared_folder~ : String)
  /// Syntax: `\\?\<L>:\`
  ///
  /// Example: `\\?\C:\`
  VerbatimVolumeLetter(Char)
  /// Syntax: `\\?\Volume{<GUID>}\`
  ///
  /// Example: `\\?\Volume{26a21bda-a627-11d7-9931-806e6f6e6963}\`
  ///
  /// Warning: this letter is case-insensitive.
  ///
  /// [Microsoft Enumerating Volume GUID Paths](https://learn.microsoft.com/en-us/windows/win32/fileio/enumerating-unique-volume-names)
  VerbatimVolumeGUID(String)
  /// Syntax: `\\.\<DEVICE>`
  ///
  /// Example: `\\.\COM56"`
  ///
  /// [Microsoft Win32 Device Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file#win32-device-namespaces)
  DeviceNS(device~ : String)
  /// Syntax: `\\<SERVER>\<SHARE>`
  ///
  /// Example: `\\server\share`
  UNC(hostname~ : String, shared_folder~ : String)
  /// Syntax: `<L>:\`
  ///
  /// Example: `C:\`
  ///
  /// Warning: this letter is case-insensitive.
  VolumeLetter(Char)
}

///|
pub struct UnixPath {
  directory : UnixDirectory
  file : UnixFile?
} derive(ToJson, Hash, Eq)

///|
pub struct File[Component] {
  base : Component
  extension : String
} derive(ToJson, Hash, Eq)

///|
pub typealias Directory[WinPathComponent] as WinDirectory

///|
pub typealias Directory[UnixPathComponent] as UnixDirectory

///|
pub typealias File[WinPathComponent] as WinFile

///|
pub typealias File[UnixPathComponent] as UnixFile

///|
struct Directory[Component](FixedArray[Component]) derive(ToJson, Hash, Eq)

///|
struct WinPathComponent(String) derive(ToJson, Hash, Eq)

///|
struct UnixPathComponent(String) derive(ToJson, Hash, Eq)

///|
trait PlatformPath {
  from(s : String) -> Self raise
  is_system_call_valid(s : String) -> Bool
}
