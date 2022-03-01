{
  description = "A minimal Haskell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        overlays = [ localOverlay ];
      };

      localOverlay = final: prev: {
        hello-world = prev.haskellPackages.callCabal2nix "hello-world" self { };
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system: with (pkgsForSystem system);
        let
          haskell = {
            ghc = haskellPackages.ghc;
            hls = haskell-language-server.override {
              supportedGhcVersions = [ "8107" ];
            };
          };
        in {
          packages = { inherit hello-world; };

          defaultPackage = self.packages.${system}.hello-world;

          devShell = mkShell {
            buildInputs = lib.attrValues self.packages.${system} ++ [
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
        }) // { overlay = localOverlay; };
}
