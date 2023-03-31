# Flake for using VSCode

An opinionated flake for building and composing VSCode with other flakes.
It includes a basic immutable configuration, and an immutable set of extensions.

## Use cases

### Run an instance of VSCode with the included defaults

Run:

```bash
nix develop github:waltermoreira/myvscode
```

and then execute `code`.

### Use VSCode in other flakes

To compose this flake with others, follow the example in `./examples`.
It contains a flake that uses the `myvscode` flake while tweaking the default
configuration and adding an extension.

Run the example with:

```bash
nix develop "github:waltermoreira/myvscode?dir=examples"
```

## API

`myvscode` flake provides a function:

`makeMyVSCode :: pkgs -> set -> derivation`

- `pkgs`: is a `nixpkgs` instance (for example, in the `examples` folder, there is a flake where `pkgs` contains an overlay for using the latest Rust version, thanks to the fantastic [oxalica's Rust overlay](https://github.com/oxalica/rust-overlay)).
- `set`: is an attribute set with two optional keys:
  - `extraSettings:: set`: an attribute set with configuration for VSCode. The flake appends this configuration to the default one, so it can overwrite existing options.
  - `extraExtensions:: list`: list of VSCode extensions to install (use the packages from `pkgs.vscode-extensions.*`, or use the function `pkgs.vscode-utils.extensionsFromVscodeMarketplace` to build extensions directly from VSCode Marketplace).
