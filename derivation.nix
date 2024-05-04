{ stdenv, fetchFromGitHub, openssl_1_1, harfbuzz, pkg-config, qmake, pkgs, module, version, pro, deps, ... }:

let
  katana-parser = fetchFromGitHub {
    owner = "jasenhuang";
    repo = "katana-parser";
    rev = "be6df458d4540eee375c513958dcb862a391cdd1";
    hash = "sha256-SYJFLtrg8raGyr3zQIEzZDjHDmMmt+K0po3viipZW5c=";
  };
  hyphen = fetchFromGitHub {
    owner = "hunspell";
    repo = "hyphen";
    rev = "73dd2967c8e1e4f6d7334ee9e539a323d6e66cbd";
    hash = "sha256-WIHpSkOwHkhMvEKxOlgf6gsPs9T3xkzguD8ONXARf1U=";
  };
  gumbo-parser = fetchFromGitHub {
    owner = "google";
    repo = "gumbo-parser";
    rev = "aa91b27b02c0c80c482e24348a457ed7c3c088e0";
    hash = "sha256-+607iXJxeWKoCwb490pp3mqRZ1fWzxec0tJOEFeHoCs=";
  };
  openssl = openssl_1_1.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "enable-md2" ];
  });
in
stdenv.mkDerivation {
  pname = "onlyoffice-${module}";
  inherit version;

  src = fetchFromGitHub {
    owner = "ONLYOFFICE";
    repo = "core";
    rev = "dc3a4a3ed99370472d5b59c30829807a2500a87e";
    hash = "sha256-3NoMn3wAinTZqDo9E8RHd4Tb+inqpKnMfzkd9nlPdxE=";
  };

  patches = [
    ./patches/0001-icu-link-against-system-icu.patch
    ./patches/0003-fix-import-paths.patch
    ./patches/0004-support-modern-gcc.patch
    ./patches/0005-v8-remove-depndency.patch
    ./patches/0006-UnicodeConverter-fix-missing-TRUE.patch
  ];

  postPatch = ''
    ln -s ${katana-parser} Common/3dParty/html/katana-parser
    ln -s ${gumbo-parser} Common/3dParty/html/gumbo-parser
    ln -s ${hyphen} Common/3dParty/hyphen/hyphen
    # override qt creared openssl
    sed -i 's|$$PWD/build/$$OPEN_SSL_PLATFORM/lib|${openssl.out}/lib|' Common/3dParty/openssl/openssl.pri
    sed -i 's|$$OPENSSL_LIBS_DIRECTORY/../include|${openssl.dev}/include|' Common/3dParty/openssl/openssl.pri
    sed -i 's|libssl.a|libssl.so|' Common/3dParty/openssl/openssl.pri
    sed -i 's|libcrypto.a|libcrypto.so|' Common/3dParty/openssl/openssl.pri

    cat > Common/3dParty/harfbuzz/harfbuzz.pri << EOF
      LIBS += ${harfbuzz.out}/lib/libharfbuzz.so
      INCLUDEPATH += ${harfbuzz.dev}/include/harfbuzz
    EOF
  '';

  dontWrapQtApps = true;
  qmakeFlags = [ pro ];
  hardeningDisable = [ "format" ];

  nativeBuildInputs = [
    qmake
    pkg-config
  ];

  buildInputs = deps;

  installPhase = ''
    ${pkgs.tree}/bin/tree build
    mkdir -p $out/lib
    mv build/lib/linux_64/lib${module}.* $out/lib/
  '';

  postInstall = ''
    ${pkgs.tree}/bin/tree $out
  '';

  doCheck = false;
  dontStrip = true;
}

