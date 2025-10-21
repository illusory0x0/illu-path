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
) -> Directory[T] {
  guard components.iter().all(T::is_system_call_valid) else {
    abort("Invalid path component")
  }
  unsafe_fixed_array_string_to_directory(components)
}

///|
pub fn[T : PlatformPath] Directory::from_array(
  components : Array[String],
) -> Directory[T] {
  Directory::from_fixed_array(FixedArray::from_array(components))
}

///|
pub fn[T] Directory::iter(self : Directory[T]) -> Iter[T] {
  FixedArray::iter(self.0)
}
