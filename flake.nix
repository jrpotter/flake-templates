{
  description = "Opinionated flake templates";

  outputs = { self, ... }: {
    templates = {
      elixir = {
        path = ./elixir;
        description = "A minimal Elixir flake";
      };
      haskell = {
        path = ./haskell;
        description = "A minimal Haskell flake";
      };
      jekyll = {
        path = ./jekyll;
        description = "A minimal Jekyll flake";
      };
      maven = {
        path = ./maven;
        description = "A minimal Maven flake";
      };
      postgresql = {
        path = ./postgresql;
        description = "A minimal PostgreSQL flake";
      };
      python = {
        path = ./python;
        description = "A minimal Python flake";
      };
      rust = {
        path = ./rust;
        description = "A minimal Rust flake";
      };
    };
  };
}
