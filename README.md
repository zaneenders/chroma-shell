# Chroma Shell

A basic Swift DSL for making more interactive tools of your shell.

## Getting started

Add Chroma Shell to your swift package to give it a try. 
```swift 
.package(
    url: "https://github.com/zaneenders/chroma-shell.git",
    revision: "main"),

.product(name: "ChromaShell", package: "chroma-shell"),
```

You can also clone the repo and `swift run` to try out the sample found at [TestChromaClient](Sources/TestChromaClient/TestChromaClient.swift).


### Hello world

```swift
import ChromaShell

@main
struct Scribe: ChromaShell {
    var main: some Block {
        "Hello world"
    }
}
```


## [Documentation](https://zaneenders.github.io/chroma-shell/documentation/chromashell/)

Checkout the docs for more details about the project.