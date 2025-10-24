

## Examples 

```mbt
test {
    let path = @path.Path::parse("home/username/proj/src/README.mbt.md");
    inspect(path.directory(), content="home/username/proj/src/")
    inspect(path.file().unwrap(), content="README.mbt.md")
    inspect(path.is_absolute(), content="false")
    inspect(path.is_relative(), content="true")
}
```