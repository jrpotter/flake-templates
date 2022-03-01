{
  description = "Opinionated flake templates";

  outputs = { self, ... }: {
    templates = {
      haskell = {
        path = ./haskell;
        description = "A minimal Haskell flake";
      };
      rust = {
        path = ./rust;
        description = "A minimal Rust flake";
      };
    };
  };
}
