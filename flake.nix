{
  description = "Cyberpunk 2077 remap helper";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        rubyEnv = pkgs.bundlerEnv {
          name = "cyberpunk2077_remapper";
          inherit (pkgs) ruby;
          gemdir = ./.;
        };

        updateDeps = pkgs.writeScriptBin "update-deps" (builtins.readFile
          (pkgs.substituteAll {
            src = ./update.sh;
            bundix = nixpkgs.lib.getExe pkgs.bundix;
            bundler = nixpkgs.lib.getExe' rubyEnv "bundler";
          }));
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [rubyEnv rubyEnv.wrappedRuby updateDeps];
        };
      }
    );
}
