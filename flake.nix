{
  description = "Opinionated flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-compat, flake-utils }: {
    overlay = final: prev: {
      nix-gen = prev.writeShellScriptBin "nix-gen" ''
        #!/usr/bin/env bash -e
        set -e
        TEMPLATE=$1
        DIR_NAME=$2

        # It is generally recommended the `nix` command is replaced with one
        # that is endowed with the flake subcommand or a separate `nixFlakes`
        # command is made available.
        if [ -z "$NIX_COMMAND" ]; then
          if command -v nixFlakes &> /dev/null; then
            NIX_COMMAND="nixFlakes"
          else
            NIX_COMMAND="nix"
          fi
        fi

        if [ -z "$TEMPLATE" ] || [ -z "$DIR_NAME" ]; then
          >&2 echo 'Expected `nix-gen $TEMPLATE $DIR_NAME`.'
          exit 1
        fi
        if ! command -v nix &> /dev/null; then
          >&2 echo 'Must have `nix` installed to pull template.'
          exit 1
        fi
        if ! command -v git &> /dev/null; then
          >&2 echo 'Flake functionality does not work without `git`.'
          exit 1
        fi
        # Intentionally fail if the directory already exists. We delete the
        # directory if the subshell fails.
        mkdir $DIR_NAME
        (
          cd $DIR_NAME
          trap "cd .. && rm -rf $DIR_NAME" ERR
          $NIX_COMMAND flake init -t github:jrpotter/flake-templates#$TEMPLATE
          git init
          git add .
          git commit -m "Initial commit"
          if [ -x ".githooks/pre-commit" ]; then
            git config --local core.hooksPath .githooks/
          fi
        )
        if command -v direnv &> /dev/null; then
          direnv allow $DIR_NAME
        fi
      '';
    };
    templates = {
      elixir = {
        path = ./elixir;
        description = "A minimal Elixir flake";
      };
      haskell = {
        path = ./haskell;
        description = "A minimal Haskell flake";
      };
      jekyll = {
        path = ./jekyll;
        description = "A minimal Jekyll flake";
      };
      maven = {
        path = ./maven;
        description = "A minimal Maven flake";
      };
      phoenix = {
        path = ./phoenix;
        description = "A minimal Phoenix flake";
      };
      postgresql = {
        path = ./postgresql;
        description = "A minimal PostgreSQL flake";
      };
      python = {
        path = ./python;
        description = "A minimal Python flake";
      };
      rust = {
        path = ./rust;
        description = "A minimal Rust flake";
      };
      typescript = {
        path = ./typescript;
        description = "A minimal Typescript flake";
      };
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in
    with pkgs; {
      packages = { inherit nix-gen; };

      defaultPackage = self.packages.${system}.nix-gen;

      devShell = mkShell {
        buildInputs = lib.attrValues self.packages.${system};
      };
    }));
}
