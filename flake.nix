{
  description = "My VSCode";
  inputs = {    
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , shell-utils
    }:
      with flake-utils.lib; eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        myVSCode = pkgs:
          let
            configuration = pkgs.writeTextFile {
              name = "settings";
              text = builtins.readFile ./settings.json;
              destination = "/share/settings.json";
            };
            app = pkgs.writeShellApplication {
              name = "myvscode";
              runtimeInputs = [ vscode ];
              text = ''
                mkdir -p ~/.myvscode/User
                ln -sf ${configuration}/share/settings.json ~/.myvscode/User/settings.json
                ${vscode}/bin/code --user-data-dir ~/.myvscode
              '';
            };
            vscode = pkgs.vscode-with-extensions.override {
              vscodeExtensions = with pkgs.vscode-extensions; [
                formulahendry.code-runner
                rust-lang.rust-analyzer
              ];
            };
          in
          app;
        shell = shell-utils.myShell.${system};
      in
      { 
        packages.default = myVSCode pkgs;
      });
}