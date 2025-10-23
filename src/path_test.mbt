///|
test "parse windows path" {
  let path = Path::parse("\\folder\\")
  inspect(path, content="folder\\")
  let path = Path::parse("C:\\Users")
  inspect(path, content="C:\\Users")
  let path = Path::parse("C:\\Users\\username\\main.mbt")
  inspect(path, content="C:\\Users\\username\\main.mbt")
  let path = Path::parse("C:\\Users\\username\\main")
  inspect(path, content="C:\\Users\\username\\main")
  let path = Path::parse("C:\\Users\\username\\folder\\")
  inspect(path, content="C:\\Users\\username\\folder\\")
  let path = Path::parse("\\\\?\\D:\\Pictures\\apple.png")
  inspect(path, content="\\\\?\\D:\\Pictures\\apple.png")
  let path = Path::parse(
    "\\\\?\\Volume{12345678-1234-1234-1234-1234567890AB}folder\\",
  )
  inspect(
    path,
    content="\\\\?\\Volume{12345678-1234-1234-1234-1234567890AB}folder\\",
  )
  let path = Path::parse("\\\\.\\COM56\\folder\\")
  inspect(path, content="\\\\.\\COM56\\folder\\")
  let path = Path::parse(".\\folder\\sub\\")
  inspect(path, content="folder\\sub\\")
  let path = Path::parse("\\folder\\sub\\")
  inspect(path, content="folder\\sub\\")
}
