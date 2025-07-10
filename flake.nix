

{
  description = "Python bindings for the octra library";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs}:
    let

      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      version = "${builtins.substring 0 8 lastModifiedDate}-${self.shortRev or "dirty"}";
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        octra = with final; final.callPackage ({ inShell ? false }: stdenv.mkDerivation rec {

          name = "octra-${version}";

          src = if inShell then null else ./.;

          buildInputs =
            [ 
              pkg-config
              libxml2
            ] ++ (if inShell then [
              clang
              cmake
              gcc
              git
              gnumake
              just
              nodejs_24
            ] else [

            ]);

          target = "--release";

          # buildPhase = "cargo build ${target} --frozen --offline";
          buildPhase = "";

          doCheck = true;

          # checkPhase = "cargo test ${target} --frozen --offline";
          checkPhase = "";

          # installPhase =
          #   ''
          #     mkdir -p $out
          #     cargo install --frozen --offline --path . --root $out
          #     rm $out/.crates.toml
          #   '';

          installPhase =
            ''
              mkdir -p $out
            '';

        }) {};

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) octra;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.octra);

      # Provide a 'nix develop' environment for interactive hacking.
      devShell = forAllSystems (system: self.packages.${system}.octra.override { inShell = true; });

      # A NixOS module.
      nixosModules.octra =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlay ];

          systemd.services.octra = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig.ExecStart = "${pkgs.octra}/bin/octra";
          };
        };

      # Tests run by 'nix flake check' and by Hydra.
      checks = forAllSystems
        (system:
          with nixpkgsFor.${system};

          {
            inherit (self.packages.${system}) octra;

            # A VM test of the NixOS module.
            vmTest =
              with import (nixpkgs + "/nixos/lib/testing-python.nix") {
                inherit system;
              };

              makeTest {
                nodes = {
                  client = { ... }: {
                    imports = [ self.nixosModules.octra ];
                  };
                };

              # testScript =
              #   ''
              #     start_all()
              #     client.wait_for_unit("multi-user.target")
              #     assert "Hello Nixers" in client.wait_until_succeeds("curl --fail http://localhost:8080/")
              #   '';
              # };

              testScript =
                ''

                '';
              };

          }
        );
    };
}
