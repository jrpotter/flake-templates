{
  description = "A minimal Maven flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlay = final: prev:
      let
        # We package our entire repository as a fixed output derivation for
        # use within nix. Refer to the called package for more information.
        repo = prev.callPackage "${self}/build-maven-repo.nix" { };

        hello-world-jar = prev.stdenv.mkDerivation rec {
          pname = "hello-world";
          version = "0.1.0";
          src = self;
          buildInputs = [ prev.maven ];
          nativeBuildInputs = [ prev.makeWrapper ];
          buildPhase = ''
            runHook preBuild
            mvn --offline -Dmaven.repo.local=${repo} package;
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            install -Dm644 target/${pname}-${version}.jar $out/share/java
            runHook postInstall
          '';
        };
      in {
        hello-world = prev.writeShellScriptBin "hello-world" ''
          ${prev.jre}/bin/java -jar ${hello-world-jar}/share/java
        '';
      };
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
          google-java-format
          groovy
          maven
          openjdk11
        ];
      };
    }));
}
