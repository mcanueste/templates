{
  description = "Example Bash application project.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      debug = true;
      imports = [];
      flake = {};
      perSystem = {
        self',
        inputs',
        system,
        pkgs,
        config,
        ...
      }: let
        name = "bash-hello";
        lastModifiedDate = self'.lastModifiedDate or self'.lastModified or "19700101";
        version = builtins.substring 0 8 lastModifiedDate;
      in {
        packages = {
          default = pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = with pkgs; [coreutils];
            text = ''
              echo "Hello, world!"
            '';
          };

          docker = pkgs.dockerTools.buildImage {
            inherit name;
            tag = version;
            config = {
              Cmd = ["${self'.packages.default}/bin/${name}"];
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
            };
          };
        };
      };
    };
}
