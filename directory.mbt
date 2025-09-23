///|
pub fn[T] Directory::op_get(self : Directory[T], index : Int) -> T = "%fixedarray.get"

///|
pub fn[T] Directory::length(self : Directory[T]) -> Int = "%fixedarray.length"

///|
fn[T] unsafe_fixed_array_string_to_directory(
  components : FixedArray[String],
) -> Directory[T] = "%identity"

///|
pub fn[T : PlatformPath] Directory::from_fixed_array(
  components : FixedArray[String],
) -> Directory[T] raise {
  guard components.iter().all(T::is_system_call_valid) else {
    abort("Invalid path component")
  }
  unsafe_fixed_array_string_to_directory(components)
}

///|
pub fn[T : PlatformPath] Directory::from_array(
  components : Array[String],
) -> Directory[T] raise {
  Directory::from_fixed_array(FixedArray::from_array(components))
}

///|
pub fn[T] Directory::iter(self : Directory[T]) -> Iter[T] {
  FixedArray::iter(self.0)
}

///|
test "Directory::from_array should work correctly" {
  let components : Array[String] = ["home", "user", "documents"]
  let dir : Directory[UnixPathComponent] = Directory::from_array(components)
  inspect(dir.length(), content="3")
  inspect(dir[0].0, content="home")
  inspect(dir[1].0, content="user")
  inspect(dir[2].0, content="documents")
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
