{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    poetry2nix = { url = "github:nix-community/poetry2nix"; inputs.nixpkgs.follows = "nixpkgs"; inputs.treefmt-nix.follows = "treefmt-nix"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem = { pkgs, lib, ... }:
        let
          poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

          poetry2nixCommonArgs = {
            projectDir = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                (lib.fileset.fileFilter (f: lib.hasSuffix ".py" f.name) ./hci_notifier)
                ./pyproject.toml
                ./poetry.lock
              ];
            };
          };
        in
        {
          packages.default = (poetry2nix.mkPoetryApplication poetry2nixCommonArgs).overrideAttrs {
            makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ pkgs.libnotify ]}" ];
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              (poetry2nix.mkPoetryEnv poetry2nixCommonArgs)
              poetry
              python3Packages.ipython
            ];
          };

          treefmt = {
            projectRootFile = "pyproject.toml";
            programs = {
              ruff.enable = true;
              black.enable = true;
              mypy.enable = true;
              # TODO: Get the packages directly fron config.packages.default
              mypy.directories."hci_notifier".extraPythonPackages = with pkgs.python3Packages; [
                types-requests
              ];
            };
          };
        };
    };
}
