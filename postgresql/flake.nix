{
  description = "A minimal PostgreSQL flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlay = final: prev: {
      pg_nix = prev.writeShellScriptBin "pg_nix" ''
        #!/usr/bin/env bash -e

        # Find the project root. Using `git` to determine this top-level
        # directory is fairly safe considering we need `git` for flakes to
        # work correctly.
        BASE_DIR=$(${prev.git}/bin/git rev-parse --show-toplevel)

        # Extract the database name from the command line arguments. To stay
        # consistent with `pg_ctl`, allow using either `-n` or `--db-name=`.
        CTL_ARGS=()
        while [[ $# -gt 0 ]]; do
          case $1 in
            --db-name=*)
              DB_NAME=''${1#*=}
              shift 1
              ;;
            -n)
              DB_NAME="$2"
              shift 2
              ;;
            start)
              # We override the command in this case.
              if [ ! -z "$COMMAND" ]; then
                >&2 echo "Already specified command $COMMAND."
                exit 1
              fi
              COMMAND=$1
              shift 1
              ;;
            *)
              CTL_ARGS+=("$1")
              shift 1
              ;;
          esac
        done

        if [ -z "$DB_NAME" ]; then
          >&2 echo 'You must specify a database name!'
          >&2 echo
          >&2 echo 'Either export a DB_NAME for subsequent invocations or '
          >&2 echo 'pass in a `--db-name=` or `-n` flag argument.'
          >&2 echo
          exit 1
        fi

        # Likewise assume we have a `.direnv` directory. `.gitignore` is
        # already setup to ignore this so nicely avoids polluting our root
        # directory any further.
        DB_DIR=$BASE_DIR/.direnv/db/$DB_NAME
        mkdir -p $DB_DIR

        # pg_ctl prioritizes flags that appear later so easily override any
        # of these defaults by specifying the flag again, e.g.
        # `pg_nix start -D test`.
        normal=$(tput sgr0)
        yellow=$(tput setaf 3)
        if [ "$COMMAND" = "start" ]; then
          pg_ctl start \
            -D $DB_DIR \
            -l $DB_DIR/logfile \
            -o "--unix_socket_directories='$DB_DIR'" \
            ''${CTL_ARGS[@]}
          if [ "$?" = "0" ]; then
            echo
            echo "You probably also want to create a new database and user"
            echo "if you have not done so before. Try running:"
            echo
            tput setaf 3
            echo 'createuser -h $PWD/.direnv/db/$DB_NAME postgres --superuser'
            echo 'createdb -h $PWD/.direnv/db/$DB_NAME $DB_NAME'
            tput sgr0
            echo
            echo "at the project root directory."
          fi
        else
          pg_ctl -D "$DB_DIR" ''${CTL_ARGS[@]}
        fi
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
      packages = { inherit pg_nix; };

      defaultPackage = self.packages.${system}.pg_nix;

      devShell = mkShell {
        buildInputs = lib.attrValues self.packages.${system} ++ [
          postgresql
        ];
      };
    })
  );
}
