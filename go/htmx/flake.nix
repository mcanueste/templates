{
  description = "Go HTMX Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }: let
    name = "go-htmx";
    version = "0.1.0";
  in
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
        devShells.default = pkgs.mkShell {
          inherit name;
          buildInputs = [
            pkgs.go
            pkgs.golangci-lint
            pkgs.air
          ];

          # Run on each venv activation.
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH"
          '';
        };

        packages.default = pkgs.buildGoModule {
          pname = name;
          inherit version;
          src = ./.;

          # This hash locks the dependencies of this package. It is
          # necessary because of how Go requires network access to resolve
          # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
          # details. Normally one can build with a fake sha256 and rely on native Go
          # mechanisms to tell you what the hash should be or determine what
          # it should be "out-of-band" with other tooling (eg. gomod2nix).
          # To begin with it is recommended to set this, but one must
          # remember to bump this hash when your dependencies change.
          #vendorSha256 = pkgs.lib.fakeSha256;

          vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
        };

        packages.docker = pkgs.dockerTools.buildImage {
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
            Cmd = ["echo 'Hello!'"];
            Env = [
              "PATH=/bin/"
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
        };
      };
    };
}
