{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc822" }:

let
  hsPkgs = nixpkgs.pkgs.haskell.packages.${compiler};
  hsLib = nixpkgs.pkgs.haskell.lib;
  hsPkgs' = hsPkgs.override {
    overrides = self: super: {
    };
  };
  addInstruments = pkg: hsLib.overrideCabal pkg ({ buildDepends ? [], ...}: {
    buildDepends = buildDepends ++ (with hsPkgs';
      [ cabal-install ghcid stylish-haskell hlint ]
    );
  });
  drv = hsPkgs'.callPackage ./. { };
in
(addInstruments drv).env
