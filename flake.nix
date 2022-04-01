{
  description = "A minimal Python flake";

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
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs, poetry2nix }: {
    overlay = nixpkgs.lib.composeManyExtensions [
      poetry2nix.overlay
      (final: prev: {
        hello-world = prev.poetry2nix.mkPoetryApplication {
          projectDir = ./hello-world;
          python = prev.python38;
        };
      })
    ];
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in
    with pkgs; {
      packages = { inherit hello-world; };

      defaultPackage = self.packages.${system}.hello-world;

      devShell = mkShell {
        buildInputs = [
          nodePackages.pyright
          poetry
          python38
        ];
      };
    }));
}
