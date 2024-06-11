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
        name = "bash-hello";
        version = "0.1.0";
      in {
        packages = {
          default = pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [pkgs.coreutils];
            text = ''
              echo "Hello, world!"
            '';
          };

          docker = pkgs.dockerTools.buildImage {
            inherit name;
            tag = version;
            created = "now";
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [
                pkgs.bashInteractive
                pkgs.coreutils
                self'.packages.default
              ];
              pathsToLink = ["/bin"];
            };
            config = {
              Cmd = ["bash-hello"];
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "PATH=/bin/"
              ];
            };
          };
        };
      };
    };
}
