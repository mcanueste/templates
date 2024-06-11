{
  description = "Nix Templates";

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
      }: {
        formatter = pkgs.alejandra;

        # Define a devShell with packages that are useful for templates
        devShells.default = pkgs.mkShell {
          name = "templates";
          buildInputs = [pkgs.make pkgs.just pkgs.jq];
        };

        # TODO package templates here for example runs
        # packages = {};
      };

      flake = {
        templates = {
          bash-application = {
            description = "A simple bash application template";
            path = ./templates/bash-application;
          };

          python-devshell = {
            description = "A Python development shell";
            path = ./templates/python/devshell;
          };
        };
      };
    };
}
