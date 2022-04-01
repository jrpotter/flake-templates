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

  outputs = { self, flake-compat, flake-utils, nixpkgs }: {
    overlay = final: prev: {
      hello-world = prev.haskellPackages.callCabal2nix "hello-world" self { };
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };

      haskell = {
        ghc = pkgs.haskellPackages.ghc;
        hls = pkgs.haskell-language-server.override {
          supportedGhcVersions = [ "8107" ];
        };
      };
    in
    with pkgs; {
      packages = { inherit hello-world; };

      defaultPackage = self.packages.${system}.hello-world;

      devShell = mkShell {
        buildInputs = [
          haskell.ghc
          haskell.hls
          gdb
          # GHC depends on LANG so need this package to properly interpret our
          # files with e.g. tasty-discover.
          # https://www.reddit.com/r/Nix/comments/jyczts/nixshell_locale_issue/
          glibcLocales
          haskellPackages.cabal-install
          haskellPackages.ormolu
          haskellPackages.tasty-discover
        ];
      };
    }));
}
