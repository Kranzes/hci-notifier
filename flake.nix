{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    treefmt-nix = { url = "github:numtide/treefmt-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem = { pkgs, lib, config, ... }:
        let
          src = lib.fileset.toSource {
            root = ./.;
            fileset = (lib.fileset.unions [
              (lib.fileset.fileFilter (f: f.hasExt "rs") ./.)
              (lib.fileset.fileFilter (f: f.name == "Cargo.toml") ./.)
              ./Cargo.lock
            ]);
          };
          cargoToml = (lib.importTOML (src + "/Cargo.toml"));
        in
        {
          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = cargoToml.package.name;
            inherit (cargoToml.package) version;
            inherit src;
            cargoLock.lockFile = (src + "/Cargo.lock");
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.packages.default
              config.treefmt.build.devShell
            ];
            packages = [ pkgs.clippy ];
          };

          treefmt = {
            projectRootFile = "Cargo.toml";
            programs.rustfmt.enable = true;
            programs.nixpkgs-fmt.enable = true;
          };
        };
    };
}
