{
  description = "A minimal Rust flake";

  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/master";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, cargo2nix, flake-compat, flake-utils, nixpkgs, rust-overlay }: {
    overlay = nixpkgs.lib.composeManyExtensions [
      (import "${cargo2nix}/overlay") rust-overlay.overlay
      (final: prev: {
        hello-world =
          let
            rustPkgs = prev.rustBuilder.makePackageSet' {
              rustChannel = "1.56.1";
              packageFun = import ./Cargo.nix;
            };
          in
            (rustPkgs.workspace.hello-world { }).bin;
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
          cargo
          cargo2nix.packages.${system}.cargo2nix
          rls
          rustc
          rustfmt
        ];
      };
    }));
}
