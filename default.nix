{ mkDerivation, attoparsec, base, bytestring, directory, filepath
, ini, lens, optparse-applicative, split, stdenv, text
, unordered-containers, wreq
}:
mkDerivation {
  pname = "host-sink";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    attoparsec base bytestring directory filepath ini lens
    optparse-applicative split text unordered-containers wreq
  ];
  description = "Generate host sinkholes";
  license = stdenv.lib.licenses.agpl3;
}
