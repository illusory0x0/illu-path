///|
/// Black-box tests for File[Component] type
test "File struct functionality through parsing" {
  // Test Unix file extraction
  let unix_path = @path.UnixPath::parse("/home/readme.md")
  match unix_path.file {
    Some(unix_file) => inspect(unix_file.extension, content="md")
    None => fail("Expected file")
  }

  // Test Windows file extraction
  let win_path = @path.WinPath::parse("C:\\config.json")
  match win_path.file {
    Some(win_file) => inspect(win_file.extension, content="json")
    None => fail("Expected file")
  }
}

///|
test "File extension access through parsing" {
  let unix_path = @path.UnixPath::parse("/test.txt")
  match unix_path.file {
    Some(unix_file) => inspect(unix_file.extension, content="txt")
    None => fail("Expected file")
  }
  let win_path = @path.WinPath::parse("C:\\document.pdf")
  match win_path.file {
    Some(win_file) => inspect(win_file.extension, content="pdf")
    None => fail("Expected file")
  }
}

///|
test "File with no extension" {
  // Test files without extension
  let unix_path = @path.UnixPath::parse("/home/user/script")
  // Note: Files without extensions are treated as directories by the parser
  match unix_path.file {
    Some(_) => fail("Expected no file - should be treated as directory")
    None => () // Expected
  }
}

///|
test "File with empty extension" {
  // Test files ending with a dot (empty extension)
  let unix_path = @path.UnixPath::parse("/home/user/file.")
  match unix_path.file {
    Some(unix_file) => inspect(unix_file.extension, content="")
    None => fail("Expected file with empty extension")
  }
  let win_path = @path.WinPath::parse("C:\\document.")
  match win_path.file {
    Some(win_file) => inspect(win_file.extension, content="")
    None => fail("Expected file with empty extension")
  }
}

///|
test "File with multiple dots in name" {
  // Test files with multiple dots
  let unix_path = @path.UnixPath::parse("/archive/file.tar.gz")
  match unix_path.file {
    Some(unix_file) => inspect(unix_file.extension, content="gz")
    None => fail("Expected file")
  }
  let win_path = @path.WinPath::parse("C:\\backup\\data.old.bak")
  match win_path.file {
    Some(win_file) => inspect(win_file.extension, content="bak")
    None => fail("Expected file")
  }
}

///|
test "File extension property access" {
  // Test direct access to file extension property
  let unix_path = @path.UnixPath::parse("/test.txt")
  match unix_path.file {
    Some(unix_file) =>
      // Test that we can access the extension field
      inspect(unix_file.extension, content="txt")
    None => fail("Expected file")
  }

  // Test Windows file extension access
  let win_path = @path.WinPath::parse("C:\\document.pdf")
  match win_path.file {
    Some(win_file) => inspect(win_file.extension, content="pdf")
    None => fail("Expected file")
  }
}

///|
test "File equality and hashing" {
  // Test File equality through path parsing
  let unix_path1 = @path.UnixPath::parse("/test.txt")
  let unix_path2 = @path.UnixPath::parse("/test.txt")
  let unix_path3 = @path.UnixPath::parse("/other.txt")
  match (unix_path1.file, unix_path2.file, unix_path3.file) {
    (Some(file1), Some(file2), Some(file3)) => {
      inspect(file1 == file2, content="true")
      inspect(file1 == file3, content="false")
    }
    _ => fail("Expected files in all paths")
  }
}

///|
test "File JSON serialization" {
  let unix_path = @path.UnixPath::parse("/config.json")
  match unix_path.file {
    Some(unix_file) => {
      let _json = unix_file.to_json()
      inspect(unix_file.to_json().stringify().length() > 0, content="true")
    }
    None => fail("Expected file")
  }
  let win_path = @path.WinPath::parse("C:\\settings.ini")
  match win_path.file {
    Some(win_file) => {
      let _json = win_file.to_json()
      inspect(win_file.to_json().stringify().length() > 0, content="true")
    }
    None => fail("Expected file")
  }
}

///|
test "File::parse basic functionality" {
  // Test simple filename with extension using UnixFile type alias
  let file1 : @path.UnixFile = @path.File::parse("readme.txt")
  inspect(file1.base, content="readme")
  inspect(file1.extension, content="txt")

  // Test filename without extension  
  let file2 : @path.UnixFile = @path.File::parse("script")
  inspect(file2.base, content="script")
  inspect(file2.extension, content="")

  // Test filename with multiple dots
  let file3 : @path.UnixFile = @path.File::parse("archive.tar.gz")
  inspect(file3.base, content="archive.tar")
  inspect(file3.extension, content="gz")
}

///|
test "File::parse with Windows components" {
  // Test with Windows path components
  let win_file1 : @path.WinFile = @path.File::parse("document.pdf")
  inspect(win_file1.base, content="document")
  inspect(win_file1.extension, content="pdf")

  // Test complex filename
  let win_file2 : @path.WinFile = @path.File::parse("backup.old.zip")
  inspect(win_file2.base, content="backup.old")
  inspect(win_file2.extension, content="zip")
}

///|
test "File::parse edge cases" {
  // Test hidden files (starting with dot)
  let file1 : @path.UnixFile = @path.File::parse(".gitignore")
  inspect(file1.base, content=".gitignore")
  inspect(file1.extension, content="")

  // Test filename ending with dot (empty extension)
  let file2 : @path.UnixFile = @path.File::parse("tempfile.")
  inspect(file2.base, content="tempfile")
  inspect(file2.extension, content="")

  // Test filename with just a dot
  let file3 : @path.UnixFile = @path.File::parse(".")
  inspect(file3.base, content=".")
  inspect(file3.extension, content="")
}

///|
test "File::parse error handling" {
  // Test empty filename
  let result = try? (@path.File::parse("") : @path.UnixFile)
  match result {
    Ok(_) => fail("Expected error for empty filename")
    Err(error) =>
      inspect(error.to_string().contains("Empty filename"), content="true")
  }
}

///|
test "File::parse consistency with Show trait" {
  // Test that parsing and then converting to string gives consistent results
  let original_names = ["config.json", "script", "archive.tar.gz", ".hidden"]
  for name in original_names {
    let parsed_file : @path.UnixFile = @path.File::parse(name)
    let reconstructed = parsed_file.to_string()
    inspect(reconstructed == name, content="true")
  }
}
