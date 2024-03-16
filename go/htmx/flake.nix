{
  description = "Go Template with Nix for HTMX Projects";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # to work with older version of flakes
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

    # Generate a user-friendly version number.
    version = builtins.substring 0 8 lastModifiedDate;
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          gopls
          gotools
          go-tools

          air
        ];
      };
    });

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      go-hello = pkgs.buildGoModule {
        pname = "go-htmx";
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
    });

    defaultPackage = forAllSystems (system: self.packages.${system}.go-hello);
  };
}
