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
    overlay = final: prev:
      let
        set_environment = ''
          function no_db_name() {
            local RESET=$(tput sgr0)
            local ITALIC=$(tput sitm)
            local YELLOW=$(tput setaf 3)
            local MAGENTA=$(tput setaf 5)

            >&2 echo -n "You must set the ''${ITALIC}DB_NAME$RESET environment "
            >&2 echo    "variable!"
            >&2 echo
            >&2 echo -n "We recommend doing so by adding the following line to "
            >&2 echo    "the $YELLOW.envrc$RESET file:"
            >&2 echo
            >&2 echo -n "''${MAGENTA}export$RESET ''${ITALIC}DB_NAME=<name>"
            >&2 echo    "$RESET"
            >&2 echo
            >&2 echo -n "Alternatively, invoke ''${MAGENTA}export$RESET "
            >&2 echo -n "manually or prefix commands with "
            >&2 echo    "''${ITALIC}DB_NAME=<name>.$RESET"
            exit 1
          }

          if [ -z "$DB_NAME" ]; then
            no_db_name
          fi

          # Find the project root. Using `git` to determine this top-level
          # directory is fairly safe considering we need `git` for flakes to
          # work correctly.
          if [ -z "$PROJECT_DIR" ]; then
            PROJECT_DIR=$(${prev.git}/bin/git rev-parse --show-toplevel)
          fi

          # Assume we have a `.direnv` directory. `.gitignore` is already setup
          # to ignore this so nicely avoids polluting our root directory any
          # further.
          if [ -z "$DB_DIR" ]; then
            DB_DIR=$PROJECT_DIR/.direnv/db/$DB_NAME
          fi
        '';

        pg_ctl = prev.writeShellScriptBin "pg_ctl" ''
          #!/usr/bin/env bash -e

          ${set_environment}

          CTL_ARGS=()
          while [[ $# -gt 0 ]]; do
            case $1 in
              -h|--help)
                ${prev.postgresql}/bin/pg_ctl --help
                exit 0
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

          # pg_ctl prioritizes flags that appear later so easily override any
          # of these defaults by specifying the flag again.
          mkdir -p $DB_DIR
          if [ "$COMMAND" = "start" ]; then
            ${prev.postgresql}/bin/pg_ctl start \
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
              echo 'createuser postgres --superuser'
              echo 'createdb $DB_NAME'
              tput sgr0
              echo
              echo "at the project root directory."
            fi
          else
            ${prev.postgresql}/bin/pg_ctl -D "$DB_DIR" ''${CTL_ARGS[@]}
          fi
        '';

        createdb = prev.writeShellScriptBin "createdb" ''
          #!/usr/bin/env bash -e
          ${set_environment}
          ${prev.postgresql}/bin/createdb -h "$DB_DIR" "$@"
        '';

        createuser = prev.writeShellScriptBin "createuser" ''
          #!/usr/bin/env bash -e
          ${set_environment}
          ${prev.postgresql}/bin/createuser -h "$DB_DIR" "$@"
        '';
      in
      {
        postgresql = prev.symlinkJoin {
          name = "postgresql";
          paths = [ pg_ctl createdb createuser prev.postgresql ];
          buildInputs = [ prev.makeWrapper ];
        };
      };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in
    with pkgs; {
      packages = { inherit postgresql; };

      defaultPackage = self.packages.${system}.postgresql;

      devShell = mkShell {
        buildInputs = lib.attrValues self.packages.${system};
      };
    })
  );
}
