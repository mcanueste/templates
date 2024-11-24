{
  description = "Rust CLI with Clap";

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
        name = "cli"; # TODO: Rename
        version = self'.rev or "dirty";
      in {
        packages = {
          default = pkgs.rustPlatform.buildRustPackage {
            inherit version;
            pname = name;
            src = ./.;
            cargoSha256 = "";
          };
        };

        devShells = {
          default = pkgs.mkShell rec {
            inputsFrom = [self'.packages.default];

            nativeBuildInputs = [
              pkgs.pkg-config
            ];

            buildInputs = [
              pkgs.clippy
            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
            RUST_BACKTRACE = 1;
          };
        };
      };
    };
}
