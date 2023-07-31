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
    let
      makeMyVSCode =
        pkgs:
        { extraSettings ? { }
        , extraExtensions ? [ ]
        }:
        let

          # (string, set) -> string
          appendAsJSON = string: json:
            builtins.toJSON ((builtins.fromJSON string) // json);

          configuration = pkgs.writeTextFile {
            name = "settings";
            text = appendAsJSON (builtins.readFile ./settings.json) extraSettings;
            destination = "/share/settings.json";
          };

          app = pkgs.writeShellApplication {
            name = "code";
            runtimeInputs = [ vscode pkgs.rsync ];
            text = ''
              BASE_DIR=$(pwd)/.myvscode
              mkdir -p "$BASE_DIR"/User
              [ ! -f "$BASE_DIR"/User/settings.json ] && \
                rsync -a ${configuration}/share/settings.json "$BASE_DIR"/User/
              chmod u+rw "$BASE_DIR"/User/settings.json
              ${vscode}/bin/code --user-data-dir "$BASE_DIR"
            '';
          };

          vscode = pkgs.vscode-with-extensions.override {
            vscodeExtensions = with pkgs.vscode-extensions; [
              formulahendry.code-runner
              rust-lang.rust-analyzer
              vscodevim.vim
            ] ++ extraExtensions;
          };
        in
        app;

      installables = with flake-utils.lib; eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          shell = shell-utils.myShell.${system};
          code = makeMyVSCode pkgs { };
        in
        {
          packages.default = code;
          devShells.default = shell {
            packages = [ code ];
          };
        });
    in
    installables // { inherit makeMyVSCode; };
}
