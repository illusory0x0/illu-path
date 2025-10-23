///|
test "parse windows path" {
  let path = Path::parse("\\folder\\")
  inspect(path, content="folder\\")
  let path = Path::parse("C:\\Users")
  inspect(path, content="C:\\Users")
  let path = Path::parse("C:\\Users\\username\\main.mbt")
  inspect(path, content="C:\\Users\\username\\main.mbt")
}
