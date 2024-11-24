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
          buildInputs = [
            pkgs.gnumake
            pkgs.just
            pkgs.jq
          ];
        };
      };

      flake = {
        templates = {
          bash-application = {
            description = "Bash application template";
            path = ./bash/application;
          };

          go-htmx = {
            description = "Go HTML application template";
            path = ./go/htmx;
          };

          rust-hello = {
            description = "Rust application template";
            path = ./rust/hello;
          };

          rust-clap = {
            description = "Rust CLI with Clap template";
            path = ./rust/clap;
          };

          rust-bevy = {
            description = "Rust bevy game engine template";
            path = ./rust/bevy;
          };

          python-typer = {
            description = "Typer CLI template";
            path = ./python/typer;
          };

          python-django = {
            description = "Python Django framework template";
            path = ./python/django;
          };

          python-devshell = {
            description = "Python development shell template";
            path = ./python/devshell;
          };

          reco-default = {
            description = "Recogni Default Flake";
            path = ./reco/default;
          };

          reco-sdk = {
            description = "Recogni SDK Flake";
            path = ./reco/sdk;
          };
        };
      };
    };
}
