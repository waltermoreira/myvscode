{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
    myvscode.url = "path:/Users/waltermoreira/repos/myvscode";
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
        };
        vscode = myvscode.app pkgs;
        shell = shell-utils.myShell.${system};
      in
      {
        devShells.default = shell {
          packages = [ vscode pkgs.rust-bin.stable.latest.default ];
        };
      });
}
