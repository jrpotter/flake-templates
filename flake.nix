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
      rust = {
        path = ./rust;
        description = "A minimal Rust flake";
      };
    };
  };
}
