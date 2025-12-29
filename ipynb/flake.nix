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
        pythonEnv_unstable = u_pkgs.python312.withPackages (
          ps: with ps; [
            numpy
            matplotlib
            scipy
            pandas
            astropy

            jupyter
            ipykernel

            jupyterlab-lsp
            python-lsp-server
            jupyterlab-vim
          ]
        );
      in
      {
        devShells.${system}.default = pkgs.mkShell {
          name = "Jupyter HEP Development Shell";
          buildInputs = [
            pkgs.root
            pythonEnv_unstable
          ];

          shellHook = ''
            export "JUPYTER_CONFIG_DIR=/tmp"
            python -m ipykernel install --user --name nix-environment --display-name="Python Env (Nix shell)"
            jupyter lab
          '';
        };
      }
    );
}
