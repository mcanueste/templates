{
  description = "Bevy Game Engine Environment";

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
      ];
      perSystem = {
        self',
        inputs',
        system,
        pkgs,
        config,
        ...
      }: let
        name = "bevy-engine";
        version = "0.1.0";
      in {
        packages = {
          default = pkgs.rustPlatform.buildRustPackage {
            inherit version;
            cargoSha256 = "";
            pname = name;
            src = ./.;
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

              pkgs.udev
              pkgs.alsa-lib

              pkgs.clang
              pkgs.lld

              pkgs.vulkan-tools
              pkgs.vulkan-headers
              pkgs.vulkan-loader
              pkgs.vulkan-validation-layers

              # To use the x11 feature
              # pkgs.xorg.libX11
              # pkgs.xorg.libXcursor
              # pkgs.xorg.libXi
              # pkgs.xorg.libXrandr

              # To use the wayland feature
              pkgs.wayland
              pkgs.libxkbcommon
            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
            RUST_BACKTRACE = 1;
          };
        };
      };
    };
}
