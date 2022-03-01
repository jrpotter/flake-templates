# flake-templates

A collection of opinionated Nix flake templates to be used in new projects. To
use, run:

```bash
nix flake init -t github:jrpotter/flake-templates#<template>
```

where `<template>` is the name of a subdirectory found in this project. For
example, to construct a new Haskell project run

```bash
nix flake init -t github:jrpotter/flake-templates#haskell
```
