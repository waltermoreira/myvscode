{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
    myvscode.url = "path:/Users/waltermoreira/repos/myvscode";
    #    myvscode.url = "github:waltermoreira/myvscode";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , shell-utils
    , myvscode
    , rust-overlay
    }:
      with flake-utils.lib; eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
          config.allowUnfree = true;
        };
        shell = shell-utils.myShell.${system};

        # Configure your instance of VSCode here:
        vscode = myvscode.makeMyVSCode pkgs {
          extraSettings = {
            "editor.minimap.enabled" = false;
          };
          extraExtensions = [
            pkgs.vscode-extensions.bbenoist.nix
          ];
        };
      in
      {
        devShells.default = shell {
          packages = [ vscode pkgs.rust-bin.stable.latest.default ];
        };
      });
}
