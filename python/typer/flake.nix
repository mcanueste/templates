{
  description = "Typer CLI Hello World";

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
        pythonPackages = pkgs.python311Packages;

        install-deps = pkgs.writeShellScriptBin "install-deps" ''
          #!/usr/bin/env bash
          uv pip install --no-deps -r requirements/requirements.txt -r requirements/requirements-dev.txt
        '';

        compile-deps = pkgs.writeShellScriptBin "compile-deps" ''
          #!/usr/bin/env bash
          uv pip compile \
            --upgrade \
            --no-header \
            --generate-hashes \
            --emit-index-annotation \
            --annotation-style line \
            -o requirements/requirements.txt \
            requirements/requirements.in

          uv pip compile \
            --upgrade \
            --no-header \
            --generate-hashes \
            --emit-index-annotation \
            --annotation-style line \
            -o requirements/requirements-dev.txt \
            requirements/requirements-dev.in
        '';
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # allow unfree packages, i.e. cuda packages
        };

        devShells.default = pkgs.mkShell {
          name = "devshell";
          venvDir = "./.venv";
          buildInputs = [
            pythonPackages.python # python interpreter
            pythonPackages.venvShellHook # venv hook for creating/activating

            # system packages to install to the environment
            pkgs.uv
            pkgs.pyright
            pkgs.pre-commit

            # scripts
            install-deps
            compile-deps
          ];

          # Run only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
          '';

          # Run on each venv activation.
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH"
          '';
        };
      };
    };
}
