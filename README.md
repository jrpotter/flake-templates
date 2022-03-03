# flake-templates

A collection of opinionated Nix flake templates to be used in new projects.
The `main` branch holds the collection of templates to be used by `nix-gen`. The
other branches, named after each template, contain just the template itself.
This way, if one of the templates exposes a command you want to include in
another flake, you can update the input to instead be e.g.

```nix
{
  inputs = {
    psql-template.url = "github:jrpotter/flake-templates/postgresql";
  };

  # ...
}
```

## Usage

This repository holds templates to be used with Nix for reproducible builds.
First [install Nix](https://nixos.org/download.html) if you do not currently
have it on your system. Afterward, enable [flakes](https://nixos.wiki/wiki/Flakes)
by adding line

```
experimental-features = nix-command flakes
```

to `$HOME/.config/nix/nix.conf`. You may then use `nix build` and `nix develop`.
To makes things easier still, we recommend using [Home Manager](https://github.com/nix-community/home-manager)
to install [direnv](https://github.com/direnv/direnv) and [nix-direnv](https://github.com/nix-community/nix-direnv).
This lets you run `direnv allow` within a directory containing an `.envrc` file
(which many of the templates do) to automatically invoke `nix develop` on
changes to `flake.nix`.

To copy a template into a new `<project>` directory, run:

```bash
mkdir <project> && cd <project> && git init
nix flake init -t github:jrpotter/flake-templates#<template>
direnv allow
```

## Installation

Alternatively, this repository exposes a `nix-gen` command that can perform the
above commands in one fell swoop:

```bash
nix-gen haskell new-project
```

Import the above via [home-manager](https://github.com/nix-community/home-manager):

```nix
{
  inputs = {
    nix-gen.url = "github:jrpotter/flake-templates/main";
  };

  # ...

  configuration = { ... }: {
    home.packages = [
      nix-gen.defaultPackage.${system}
    ];
  };
}
```
