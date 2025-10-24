

## Examples 

```mbt
test {
    let path = @path.Path::parse("src/README.mbt.md");
    inspect(path.directory(), content="src/")
}
```