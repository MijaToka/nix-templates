{
  description = "A flake to setup python jupyter notebooks in a nix-shell for use in HEP";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    unstable-nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
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

        jupyterBase =
          ps: with ps; [
            jupyter
            ipykernel

            jupyterlab-lsp
            python-lsp-server
            jupyterlab-vim
          ];

        physicsPackages =
          ps:
          (
            (jupyterBase ps)
            ++ (with ps; [
              numpy
              matplotlib
              scipy
              pandas
              astropy
            ])
          );

        minimal-pkgs = u_pkgs.python312.withPackages jupyterBase;
        default-pkgs = u_pkgs.python312.withPackages physicsPackages;

        installHook = kernelName: displayName: ''
          mkdir -p /tmp/.jupyter
          export JUPYTER_CONFIG_DIR=/tmp/.jupyter
          python -m install \
          --name ${kernelName} \
          --display-name "${displayName}"

          jupyter lab
        '';
      in
      {
        devShells = {
          default = pkgs.mkShell {
            name = "Basic Physics ipynb development shell";
            buildInputs = [
              default-pkgs
            ];
            shellHook = installHook "physics-jupyter" "Nix Jupyter Environment";
          };

          minimal = pkgs.mkShell {
            name = "Minimal Jupyter HEP Development Shell";
            buildInputs = [
              minimal-pkgs
            ];
            shellHook = installHook "minimal-jupyter" "Minimal Jupyter Environment";
          };

          root = {
            name = "ROOT Jupyter HEP Development Shell";
            buildInputs = [
              default-pkgs
              pkgs.root
            ];

            shellHook = installHook "ROOT-jupyter" "ROOT Environment";
          };
        };
      }
    );
}
