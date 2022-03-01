{
  description = "Opinionated flake templates";

  outputs = { self, ... }: {
    templates = {
      haskell = {
        path = ./haskell;
        description = "A minimal Haskell flake";
      };
    };
  };
}
