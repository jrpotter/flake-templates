{
  description = "A minimal Rust flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    cargo2nix.url = "github:cargo2nix/cargo2nix/master";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, cargo2nix, rust-overlay }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        overlays = [
          (import "${cargo2nix}/overlay") rust-overlay.overlay
          localOverlay
        ];
      };

      localOverlay = final: prev:
        let
          rustPkgs = prev.rustBuilder.makePackageSet' {
            rustChannel = "1.56.1";
            packageFun = import ./Cargo.nix;
          };
        in {
          hello-world = (rustPkgs.workspace.hello-world { }).bin;
        };
    in
    flake-utils.lib.eachDefaultSystem
      (system: with (pkgsForSystem system); {
        packages = { inherit hello-world; };

        defaultPackage = self.packages.${system}.hello-world;

        devShell = mkShell {
          buildInputs = lib.attrValues self.packages.${system} ++ [
            cargo
            rls
            rustc
            rustfmt
          ];
        };
      }) // { overlay = localOverlay; };
}
