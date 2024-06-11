{
  description = "Example Typer CLI application project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    nixpkgs-python.url = "github:cachix/nixpkgs-python"; # cache for all different python versions

    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://devenv.cachix.org"
      "https://nixpkgs-python.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
    ];
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    devenv,
    nixpkgs-python,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # systems = nixpkgs.lib.systems.flakeExposed;
      systems = ["x86_64-linux"];
      debug = true;
      imports = [
        inputs.devenv.flakeModule
      ];
      flake = {};
      perSystem = {
        self',
        inputs',
        system,
        pkgs,
        config,
        ...
      }: let
        name = "typer-hello";
        lastModifiedDate = self'.lastModifiedDate or self'.lastModified or "19700101";
        version = builtins.substring 0 8 lastModifiedDate;
      in {
        # packages = {
        #   # default = pkgs.python39Packages.buildPythonPackage {
        #   default = pkgs.python39Packages.buildPythonApplication {
        #     inherit name version;
        #     pyproject = true;
        #     src = ./.;
        #     build-system = [
        #       pkgs.python39Packages.setuptools-scm
        #     ];
        #     doCheck = false;
        #     # buildInputs = []; # build and/or run-time (ie. non-Python dependencies)
        #     # nativeBuildInputs = []; # build-time only (ie. setup_requires)
        #     # propagatedBuildInputs = []; # build-time only propogated (ie. install_requires)
        #     # nativeCheckInputs = []; # checkPhase only (ie. tests_require)
        #     # pythonRuntimeDepsCheckHook = "ls -alF";
        #   };
        # };
        packages.default = pkgs.dockerTools.streamNixShellImage {
          inherit name;
          tag = "latest";
          drv = config.packages.container-shell;
        };
        # packages.default = pkgs.dockerTools.buildImage config.packages.container-shell;

        devenv.shells.default = {
          inherit name;

          languages.python = {
            enable = true;
            package = nixpkgs-python.packages.${system}."3.9";
            venv = {
              enable = true;
              quiet = true;
            };
          };

          packages = [
            # config.packages.default
            pkgs.uv
          ];

          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          devcontainer.enable = true;
          # containers = {
          #   ${name} = {
          #     inherit name;
          #   };
          # };

          env = {
            # Environment variables to be exposed inside the developer environment.
            # NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
            # NIX_LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc]}";
          };

          # enterShell = ''
          #   uv pip install -r requirements.txt
          # '';

          pre-commit.hooks = {
            # format nix code
            alejandra.enable = true;
            # lint shell scripts
            shellcheck.enable = true;
            # format ruff for python code
            ruff.enable = true;
          };

          starship.enable = true;
        };
      };
    };
}
