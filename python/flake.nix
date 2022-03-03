{
  description = "A minimal Python flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        overlays = [ localOverlay ];
      };

      localOverlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          hello-world = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./hello-world;
            python = prev.python38;
          };
        })
      ];
    in
    flake-utils.lib.eachDefaultSystem (system: with (pkgsForSystem system); {
      packages = { inherit hello-world; };

      defaultPackage = self.packages.${system}.hello-world;

      devShell = mkShell {
        buildInputs = lib.attrValues self.packages.${system} ++ [
          nodePackages.pyright
          poetry
          python38
        ];
      };
    }) // { overlay = localOverlay; };
}
