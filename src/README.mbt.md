

## Examples 

### Path Kinds Examples 

```mbt
test "Unix relative path" {
    let path = @path.Path::parse("home/username/proj/src/README.mbt.md");
    inspect(path.directory(), content="home/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="false")
    inspect(path.is_relative(), content="true")
    inspect(path.is_root_path(), content="false")
}
```


```mbt
test "Unix absolute path" {
    let path = @path.Path::parse("/home/username/proj/src/README.mbt.md");
    inspect(path.directory(), content="home/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="true")
    inspect(path.is_relative(), content="false")
    inspect(path.is_root_path(), content="true")
}
```

```mbt 
test "Windows relative path" {
    let path = @path.Path::parse("Users\\username\\proj\\src\\README.mbt.md");
    // This is used for Debug output 
    inspect(path.directory(), content="Users/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="false")
    inspect(path.is_relative(), content="true")
    inspect(path.is_root_path(), content="false")
}
```

```mbt
test "Windows absolute path" {
    let path = @path.Path::parse("C:\\Users\\username\\proj\\src\\README.mbt.md");
    // This is used for Debug output 
    inspect(path.directory(), content="Users/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="true")
    inspect(path.is_relative(), content="false")
    inspect(path.is_root_path(), content="true")
}
```


```mbt
test "Windows relative root path" {
    let path = @path.Path::parse("\\Users\\username\\proj\\src\\README.mbt.md");
    // This is used for Debug output 
    inspect(path.directory(), content="Users/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="false")
    inspect(path.is_relative(), content="true")
    inspect(path.is_root_path(), content="true")
}
```