final: prev:
{
  jdk22 = prev.jdk22.overrideAttrs (old: rec {
    buildInputs = old.buildInputs ++ [ final."llvm" ];
    configureFlags = old.configureFlags ++ [
      "--with-hsdis=llvm"
      "--with-llvm=${final.llvm.dev}"
    ];
    buildPhase = ''
      ${prev.buildPhase or ""}
      make build-hsdis
      make install-hsdis
    '';
  });
}
