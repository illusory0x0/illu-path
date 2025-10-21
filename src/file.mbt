///|
pub fn[Component : PlatformPath] File::parse(
  s : StringView,
) -> File[Component] raise {
  if s.is_empty() {
    raise Failure("Empty filename")
  }
  let (base, ext) = split_filename(s.to_string())
  File::{ base: Component::from(base), extension: ext }
}
