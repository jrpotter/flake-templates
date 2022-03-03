# hello-world

## Building

To re-generate the `Cargo.nix` file, use `cargo2nix` after generating a
`Cargo.lock` file:

```bash
cargo build && cargo2nix -f
```

## Formatting

A `pre-commit` file is included in `.githooks` to ensure consistent formatting.
Run the following to configure `git` to using it:

```bash
git config --local core.hooksPath .githooks/
```
