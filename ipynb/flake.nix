{
  description = "A flake to setup python jupyter notebooks in a nix-shell for use in HEP";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    unstable-nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable-nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        u_pkgs = unstable-nixpkgs.legacyPackages.${system};

        jupyter_pkgs = u_pkgs.python312.withPackages (
          ps: with ps; [
            jupyter
            ipykernel

            jupyterlab-lsp
            python-lsp-server
            jupyterlab-vim
          ]
        );
        physics_pkgs = u_pkgs.python312.withPackages (
          ps: with ps; [
            numpy
            matplotlib
            scipy
            pandas
            astropy
          ]
        );
      in
      {
        devShells.${system} = {
          default = pkgs.mkShell {
            name = "Basic Physics ipynb development shell";
            buildInputs = [
              jupyter_pkgs
              physics_pkgs
            ];
            shellHook = ''
              export "JUPYTER_CONFIG_DIR=/tmp"
              python -m ipykernel install --user --name minimal-nix-environment --display-name="Nix shell"
              jupyter lab
            '';
          };

          minimal = pkgs.mkShell {
            name = "Minimal Jupyter HEP Development Shell";
            buildInputs = [
              jupyter_pkgs
            ];

            shellHook = ''
              export "JUPYTER_CONFIG_DIR=/tmp"
              python -m ipykernel install --user --name root-nix-environment --display-name="Minimal Nix shell"
              jupyter lab
            '';
          };

          root = {
            name = "ROOT Jupyter HEP Development Shell";
            buildInputs = [
              jupyter_pkgs
              physics_pkgs
              pkgs.root
            ];

            shellHook = ''
              export "JUPYTER_CONFIG_DIR=/tmp"
              python -m ipykernel install --user --name root-nix-environment --display-name="ROOT Nix shell"
              jupyter lab
            '';
          };
        };
      }
    );
}
