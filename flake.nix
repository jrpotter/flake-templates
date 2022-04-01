{
  description = "A minimal Phoenix flake";

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
    postgresql-template.url = "github:jrpotter/flake-templates/postgresql";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs, postgresql-template }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      with pkgs; {
        devShell = mkShell {
          buildInputs = [
            elixir
            elixir_ls
            postgresql-template.packages.${system}.postgresql
          ];
        };
      });
}
