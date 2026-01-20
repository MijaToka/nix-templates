{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.stdenv.mkDerivation {
  name = "pdf";
  src = ./.;
  buildInputs = with pkgs; [
    (texlive.combine {
      inherit (texlive)
        # Base LaTeX
        scheme-basic

        # Build tooling
        latexmk
        biblatex
        biber

        # Core math + symbols
        collection-latex
        collection-mathscience

        # siunitx, cleveref, geometry, titlesec, sectsty, etc.
        collection-latexextra

        # graphicx, subfigure, wrapfig
        collection-latexrecommended

        # tikz, pgf
        collection-pictures

        # fontenc, pifont
        collection-fontsrecommended

        # hyperref, xcolor
        hyperref
        ;
    })
  ];
  buildPhase = ''
    mkdir -p .cache/latex
    latexmk -interaction=nonstopmode -auxdir=.cache/latex -pdf main.tex
  '';
  installPhase = ''
    mkdir -p $out
    cp main.pdf $out
  '';
}
