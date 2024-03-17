{
  description = "Example Bash application project.";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});

    # to work with older version of flakes
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 8 lastModifiedDate;
    name = "bash-hello";
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          beautysh
          shellharden
          shellcheck
        ];
      };
    });

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = self.packages.${system}.${name};
      bash-hello = pkgs.writeShellApplication {
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
          Cmd = ["${self.packages.${system}.default}/bin/${name}"];
          Env = [
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
        };
      };
    });
  };
}
