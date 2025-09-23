# MoonBit Path Library

A cross-platform path manipulation library for MoonBit that provides robust handling of both Unix and Windows file system paths.

## Features

- **Cross-platform**: Automatically detects and handles both Unix and Windows path formats
- **Type-safe**: Strong typing with separate types for Unix and Windows paths
- **Comprehensive parsing**: Handles drive letters, directories, files, and extensions
- **Path manipulation**: Easy construction and deconstruction of path components
- **Standards compliant**: Follows platform-specific path conventions

## Quick Start

```moonbit
///|
test "basic usage" {
  // Parse different path formats automatically
  let unix_path = @path.Path::parse("/home/user/document.txt")
  let windows_path = @path.Path::parse("C:\\Users\\John\\file.pdf")

  // The library automatically detects the format
  inspect(unix_path.to_string(), content="/home/user/document.txt")
  inspect(windows_path.to_string(), content="C:\\Users\\John\\file.pdf")
}
```

## API Overview

### Main Types

- `Path`: Union type representing either Unix or Windows paths
- `UnixPath`: Unix-style paths (e.g., `/home/user/file.txt`)
- `WinPath`: Windows-style paths (e.g., `C:\\Users\\file.txt`)
- `File[Component]`: Represents a file with base name and extension
- `Directory[Component]`: Represents a directory structure

### Path Parsing

```moonbit
///|
test "path parsing examples" {
  // Unix paths
  let unix_file = @path.Path::parse("/etc/config/settings.conf")
  let _unix_dir = @path.Path::parse("/home/user/documents")
  let _unix_root = @path.Path::parse("/")

  // Windows paths
  let win_file = @path.Path::parse("D:\\Documents\\readme.txt")
  let _win_dir = @path.Path::parse("C:\\Program Files\\MyApp")
  let _win_root = @path.Path::parse("E:")

  // Relative paths (treated as Unix by default)
  let relative = @path.Path::parse("relative/path/file.txt")
  inspect(unix_file.to_string(), content="/etc/config/settings.conf")
  inspect(win_file.to_string(), content="D:\\Documents\\readme.txt")
  inspect(relative.to_string(), content="/relative/path/file.txt")
}
```

### Working with Path Components

```moonbit
///|
test "path components" {
  let path = @path.Path::parse("C:\\Users\\John\\document.pdf")
  match path {
    @path.WPath(win_path) => {
      // Access drive letter
      inspect(win_path.disk, content="C")

      // Access directory components
      inspect(win_path.directory.length(), content="2")
      inspect(win_path.directory[0].to_string(), content="Users")
      inspect(win_path.directory[1].to_string(), content="John")

      // Access file information
      match win_path.file {
        Some(file) => {
          inspect(file.base.to_string(), content="document")
          inspect(file.extension, content="pdf")
        }
        None => fail("Expected file")
      }
    }
    _ => fail("Expected Windows path")
  }
}
```

### Error Handling

```moonbit
///|
test "error handling" {
  // Empty paths are invalid
  let result = try? @path.Path::parse("")
  match result {
    Err(_) => inspect("empty path rejected", content="empty path rejected")
    Ok(_) => fail("Empty path should be rejected")
  }
}
```

## Platform Detection

The library automatically detects Windows paths by looking for drive letter patterns (e.g., "C:", "D:\\"). All other paths are treated as Unix-style paths.

```moonbit
///|
test "platform detection" {
  // These are detected as Windows paths
  let win1 = @path.Path::parse("C:")
  let _win2 = @path.Path::parse("D:\\folder")
  let _win3 = @path.Path::parse("z:\\file.txt")

  // These are detected as Unix paths
  let unix1 = @path.Path::parse("/")
  let _unix2 = @path.Path::parse("/home")
  let _unix3 = @path.Path::parse("relative/path")
  let _unix4 = @path.Path::parse("file.txt")

  // Verify detection
  match (win1, unix1) {
    (@path.WPath(_), @path.UPath(_)) =>
      inspect("detection works", content="detection works")
    _ => fail("Detection failed")
  }
}
```

## Use Cases

- **File system operations**: Parse and manipulate file paths before system calls
- **Cross-platform applications**: Handle paths consistently across different operating systems
- **Path validation**: Ensure path strings are well-formed before processing
- **Path construction**: Build paths programmatically with proper formatting
- **Configuration management**: Parse file paths from configuration files

## License

Apache-2.0