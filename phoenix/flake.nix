{
  description = "A minimal Phoenix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    postgresql-template.url = (
      "github:jrpotter/flake-templates/?rev=60f96614df3b7e0957496201edff23439966f257"
    );
  };

  outputs = { self, nixpkgs, flake-utils, postgresql-template }:
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
