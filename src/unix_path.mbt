///|
pub fn UnixPath::parse(s : StringView) -> UnixPath raise {
  if s == "/" {
    return UnixPath::from(directory=Directory([]))
  }
  let path_part = if s.has_prefix("/") {
    s[1:].to_string()
  } else {
    s.to_string()
  }
  let parts = if path_part.is_empty() { [] } else { split_path(path_part, '/') }
  let (dir_parts, file_opt) = if parts.is_empty() {
    ([], None)
  } else {
    let last_part = parts[parts.length() - 1]
    if has_file_extension(last_part) || is_likely_filename(last_part) {
      let dir_parts_array = Array::new()
      for i = 0; i < parts.length() - 1; i = i + 1 {
        dir_parts_array.push(parts[i])
      }
      let (base, ext) = split_filename(last_part)
      let file = File::{ base: UnixPathComponent::from(base), extension: ext }
      (dir_parts_array, Some(file))
    } else {
      (parts, None)
    }
  }
  let dir_components = dir_parts.map(UnixPathComponent::from)
  let directory = Directory(FixedArray::from_array(dir_components))
  match file_opt {
    Some(file) => UnixPath::from(directory~, file~)
    None => UnixPath::from(directory~)
  }
}

///|
pub fn UnixPath::from(directory~ : UnixDirectory, file? : UnixFile) -> UnixPath {
  UnixPath::{ directory, file }
}
