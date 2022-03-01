# flake-templates

A collection of opinionated Nix flake templates to be used in new projects.

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

where `<template>` is the name of the template you want to copy.
