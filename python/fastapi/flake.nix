{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlay = final: prev: {};
      overlays = [overlay];

      pkgs = import nixpkgs {
        inherit system overlays;
        config = {allowUnfree = true;};
      };
      fhsShell = pkgs.buildFHSUserEnv {
        name = "pyflake";
        targetPkgs = pkgs: [
          pkgs.stdenv.cc.cc.lib
          pkgs.python39Packages.pip
          pkgs.python39
          pkgs.uv
          pkgs.pixi
          pkgs.pyenv
          pkgs.devbox
          # pkgs.gcc11
          # pkgs.gcc11Stdenv.glibc
        ];
        runScript = "fish";
      };
    in {
      inherit overlay overlays;
      devShell = fhsShell.env;
    });
}
