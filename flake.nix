{
  description = "Opinionated flake templates";

  outputs = { self, ... }: {
    templates = {
      haskell = {
        path = ./haskell;
        description = "A minimal Haskell flake";
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
