{
  description = "Recogni SDK Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux" # 64bit Intel/AMD Linux
        "x86_64-darwin" # 64bit Intel Darwin (macOS)
        "aarch64-linux" # 64bit ARM Linux
        "aarch64-darwin" # 64bit ARM Darwin (macOS)
      ];
      perSystem = {
        self',
        inputs',
        system,
        pkgs,
        config,
        ...
      }: let
        pythonPackages = pkgs.python310Packages;
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # allow unfree packages, i.e. cuda packages
        };

        devShells.default = pkgs.mkShell {
          name = "devshell";
          venvDir = "./.venv";
          buildInputs = [
            pythonPackages.python
            pythonPackages.venvShellHook
            pkgs.uv
            pkgs.pixi
          ];

          # Run only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
          '';

          # Run on each venv activation.
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH"
            export PYTHONPATH="$PYTHONPATH:\
            $PWD/recogni-demo:\
            $PWD/recogni-conversion:\
            $PWD/recogni-conversion-core:\
            $PWD/recogni-core:\
            $PWD/recogni-hub:\
            $PWD/recogni-ml:\
            $PWD/recogni-profiler:\
            $PWD/recogni-torch:\
            $PWD/experiments/applications:\
            $PWD/experiments:\
            $PWD/recogni-perflab:\
            $PWD/recogni-perflab-reporting
            "
          '';
        };
      };
    };
}
