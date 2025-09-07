{
  description = "Development environment for octrajs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        octrajs = import ./octrajs.nix {
          inherit (pkgs) lib buildNpmPackage;
          inherit pkgs;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.hello
            pkgs.nodejs
            pkgs.nodePackages.npm
            pkgs.libxml2
            octrajs
          ];
        };
      }
    );
}
