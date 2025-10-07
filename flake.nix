{
  description = "A flake for the SIGMOD21 hdbscan paper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      python = pkgs.python312;

      # Find a way to propagate the submodules as part of the input directory
      python-package = python.pkgs.buildPythonPackage {
        pname = "pyhdbscan";
        version = "0.1.0";
        pyproject = true;
        src = ./.;

        # as stated here, one should disable the cmake setup:
        # https://discourse.nixos.org/t/building-python-package-with-scikit-build-core-and-cmake-dependencies-die-python/69665/2
        dontUseCmakeConfigure = true;
        dontUseCmakeBuild = true;
        dontUseCmakeInstall = true;

        build-system = with python.pkgs; [
          setuptools
        ];
        buildInputs = [
          python.pkgs.build
        ];
        nativeBuildInputs = with pkgs; [
          cmake
          ninja
        ];
      };
    in rec {
      packages.default = python-package;

      devShells.default = pkgs.mkShell {
        venvDir = ".venv";

        packages = with pkgs; [
          cmake
          ninja
          python
          python.pkgs.venvShellHook
          python.pkgs.build
          packages.default
        ];
      };
    });
}
