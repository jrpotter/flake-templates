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

where `<template>` is the name of the template you want to copy. Alternatively,
copy the following into something like `.bashrc` for less error-prone
generating:

```bash
function nix-gen() (
  set -e
  local TEMPLATE=$1
  local DIR_NAME=$2
  if [ -z "$TEMPLATE" ] || [ -z "$DIR_NAME" ]; then
    >&2 echo 'Expected `nix-gen $TEMPLATE $DIR_NAME`.'
    return 1
  fi
  if ! command -v nix &> /dev/null; then
    >&2 echo 'Must have `nix` installed to pull template.'
    return 1
  fi
  if ! command -v git &> /dev/null; then
    >&2 echo 'Flake functionality does not work without `git`.'
    return 1
  fi
  # Intentionally fail if the directory already exists. We delete the directory
  # if our subshell fails.
  mkdir $DIR_NAME
  (
    cd $DIR_NAME
    trap "cd .. && rm -rf $DIR_NAME" ERR
    nix flake init -t github:jrpotter/flake-templates#${TEMPLATE}
    git init
    git add .
    git commit -m "Initial commit"
  )
  if command -v direnv &> /dev/null; then
    direnv allow $DIR_NAME
  fi
)
```
