{
  description = "Godot 4 Rust Dev Endvironment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixgl = {
      url = "github:nix-community/nixGL/310f8e49a149e4c9ea52f1adf70cdc768ec53f8a";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    nixgl,
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
        name = "godot";
        version = "4";
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [nixgl.overlays.default];
        };

        packages = {
          default = pkgs.rustPlatform.buildRustPackage {
            inherit version;
            cargoSha256 = "";
            pname = name;
            src = ./.;
          };
        };

        devShells = {
          default = pkgs.mkShell.override {stdenv = pkgs.clangStdenv;} rec {
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

              # Godot Engine Editor
              pkgs.godot_4

              # NixGL - NOTE: This is buggy...
              # pkgs.nixgl.auto.nixGLNvidia
            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

            RUST_BACKTRACE = 1;

            # Point bindgen to where the clang library would be
            LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";

            # Make clang aware of a few headers (stdbool.h, wchar.h)
            BINDGEN_EXTRA_CLANG_ARGS = ''
              -isystem ${pkgs.llvmPackages.libclang.lib}/lib/clang/${pkgs.lib.getVersion pkgs.clang}/include
              -isystem ${pkgs.llvmPackages.libclang.out}/lib/clang/${pkgs.lib.getVersion pkgs.clang}/include
              -isystem ${pkgs.glibc.dev}/include
            '';

            # Alias the godot engine to use nixGL
            # shellHook = ''
            #   alias godot="nixGLNvidia godot -e"
            # '';
          };
        };
      };
    };
}
