{
  description = "A minimal Haskell flake";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs }:
    let
      name = "hello-world";
    in
    {
      overlay = final: prev: {
        # Overriding pattern according to https://github.com/NixOS/nixpkgs/issues/26561.
        haskellPackages = prev.haskellPackages.override (old: {
          overrides = prev.lib.composeExtensions
            (old.overrides or (_: _: {}))
            (_: _: {
              # Use `final` so downstream overrides are supplied to this.
              "${name}" = final.haskellPackages.callCabal2nix name self { };
            });
        });
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };

        ghc = pkgs.haskellPackages.ghcWithPackages (hpkgs: [
          hpkgs.cabal-install
          # hpkgs.${name}
        ]);

        hls = pkgs.haskell-language-server.override {
          supportedGhcVersions = [ "8107" ];
        };
      in
      with pkgs; {
        packages = {
          "${name}" = haskellPackages.callCabal2nix name self { };
        };

        defaultPackage = self.packages.${system}.${name};

        devShell = mkShell {
          buildInputs = [
            gdb
            ghc
            hls
            # Additional packages.
            haskellPackages.ormolu
            haskellPackages.tasty-discover
            # GHC depends on LANG so need this package to properly interpret our
            # files with e.g. tasty-discover.
            # https://www.reddit.com/r/Nix/comments/jyczts/nixshell_locale_issue/
            glibcLocales
          ];
        };
      }));
  }
