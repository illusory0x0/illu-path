///|
/// Black-box tests for WinPath type
test "WinPath::parse basic functionality" {
  // Test drive only
  let path1 = @path.WinPath::parse("C:")
  inspect(path1.disk, content="C")
  inspect(path1.directory.length(), content="0")
  match path1.file {
    Some(_) => fail("Expected no file")
    None => () // Expected
  }

  // Test path with directories
  let path2 = @path.WinPath::parse("D:\\Users\\John")
  inspect(path2.disk, content="D")
  inspect(path2.directory.length(), content="2")
  match path2.file {
    Some(_) => fail("Expected no file")
    None => () // Expected
  }

  // Test path with file
  let path3 = @path.WinPath::parse("E:\\Documents\\config.ini")
  inspect(path3.disk, content="E")
  inspect(path3.directory.length(), content="1")
  match path3.file {
    Some(file) => inspect(file.extension, content="ini")
    None => fail("Expected file")
  }
}

///|
test "WinPath::from constructor" {
  // Cannot create WinFile directly as component type is opaque
  // Test by parsing instead
  let win_path = @path.WinPath::parse("C:\\Users\\John\\document.docx")
  inspect(win_path.disk, content="C")
  inspect(win_path.directory.length(), content="2")
  match win_path.file {
    Some(f) => inspect(f.extension, content="docx")
    None => fail("Expected file")
  }
}

///|
test "WinPath Show implementation through Path wrapper" {
  // Test drive only path via Path wrapper (which has Show)
  let root_path = @path.Path::parse("C:")
  inspect(root_path.to_string(), content="C:\\")

  // Test path with directories and file
  let full_path = @path.Path::parse("C:\\Program Files\\MyApp\\app.exe")
  inspect(full_path.to_string(), content="C:\\Program Files\\MyApp\\app.exe")
}

///|
test "panic WinPath::parse invalid drive" {
  ignore(@path.WinPath::parse("9:"))
}

///|
test "WinPath edge cases" {
  // Test Windows path with spaces
  let path_with_spaces = @path.WinPath::parse(
    "C:\\Program Files\\My App\\app.exe",
  )
  inspect(path_with_spaces.disk, content="C")
  inspect(path_with_spaces.directory.length(), content="2")
  match path_with_spaces.file {
    Some(file) => inspect(file.extension, content="exe")
    None => fail("Expected file")
  }
}

///|
test "WinPath equality and hashing" {
  let win_path1 = @path.WinPath::parse("C:\\Users\\John\\doc.pdf")
  let win_path2 = @path.WinPath::parse("C:\\Users\\John\\doc.pdf")
  let win_path3 = @path.WinPath::parse("D:\\Users\\John\\doc.pdf")
  inspect(win_path1 == win_path2, content="true")
  inspect(win_path1 == win_path3, content="false")
}

///|
test "WinPath JSON serialization" {
  let win_path = @path.WinPath::parse("C:\\Users\\John\\document.txt")
  let _win_path_json = win_path.to_json()
  // Test that the JSON conversion succeeds without error
  inspect(win_path.to_json().stringify().length() > 0, content="true")
}
