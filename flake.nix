{
  description = "A minimal Jekyll flake.";

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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ruby = pkgs.ruby_2_7;
        gems = pkgs.bundlerEnv {
          inherit ruby;
          name = "pages-env";
          gemdir = self;
        };
      in with pkgs; {
        devShell = mkShell {
          buildInputs = [ bundix bundler gems ruby zlib xz ];
        };
      });
}
