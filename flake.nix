{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;

            config.permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];

            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "corefonts"
            ];
          };
          callPackage = pkgs.libsForQt5.callPackage;
          # Version in Common/3dParty/icu/icu.pri
          icu = pkgs.icu58;
          # https://github.com/ONLYOFFICE/build_tools/blob/master/scripts/core_common/modules/boost.py#L63
          boost = pkgs.boost175;
        in
        {
          packages = rec {
            UnicodeConverter = callPackage ./derivation.nix {
              module = "UnicodeConverter";
              version = "1.0.0.6";
              pro = "UnicodeConverter/UnicodeConverter.pro";
              # Version in Common/3dParty/icu/icu.pri
              deps = [ icu ];
            };
            kernel = callPackage ./derivation.nix {
              module = "kernel";
              version = "1.0.0.3";
              pro = "Common/kernel.pro";
              deps = [ UnicodeConverter ];
            };
            graphics = callPackage ./derivation.nix {
              module = "graphics";
              version = "0.0.0.1";
              pro = "DesktopEditor/graphics/pro/graphics.pro";
              deps = [ UnicodeConverter kernel ];
            };
            kernel-network = callPackage ./derivation.nix {
              module = "kernel_network";
              version = "0.0.0.1";
              pro = "Common/Network/network.pro";
              deps = [ kernel ];
            };
            cryptopp = callPackage ./derivation.nix {
              module = "CryptoPPLib";
              version = "0.0.0.1";
              pro = "Common/3dParty/cryptopp/project/cryptopp.pro";
              deps = [ boost ];
            };
            PdfFile = callPackage ./derivation.nix {
              module = "PdfFile";
              version = "0.0.0.1";
              pro = "PdfFile/PdfFile.pro";
              deps = [ UnicodeConverter kernel graphics kernel-network cryptopp ];
            };
            VbaFormat = callPackage ./derivation.nix {
              module = "VbaFormatLib";
              version = "0.0.0.1";
              pro = "MsBinaryFile/Projects/VbaFormatLib/Linux/VbaFormatLib.pro";
              deps = [ boost ];
            };
            DjVuFile = callPackage ./derivation.nix {
              module = "DjVuFile";
              version = "1.0.0.3";
              pro = "DjVuFile/DjVuFile.pro";
              deps = [ graphics kernel UnicodeConverter PdfFile ];
            };
            OdfFormat = callPackage ./derivation.nix {
              module = "OdfFormatLib";
              version = "1.0.0.0";
              pro = "OdfFile/Projects/Linux/OdfFormatLib.pro";
              deps = [ boost ];
            };
            DocFormat = callPackage ./derivation.nix {
              module = "DocFormatLib";
              version = "1.0.0.0";
              pro = "MsBinaryFile/Projects/DocFormatLib/Linux/DocFormatLib.pro";
              deps = [ boost ];
            };
            TxtXmlFormat = callPackage ./derivation.nix {
              module = "TxtXmlFormatLib";
              version = "1.0.0.0";
              pro = "TxtFile/Projects/Linux/TxtXmlFormatLib.pro";
              deps = [ boost ];
            };
            RtfFormat = callPackage ./derivation.nix {
              module = "RtfFormatLib";
              version = "1.0.0.0";
              pro = "RtfFile/Projects/Linux/RtfFormatLib.pro";
              deps = [ boost ];
            };
            HtmlFile2 = callPackage ./derivation.nix {
              module = "HtmlFile2";
              version = "1.0.0.0";
              pro = "HtmlFile2/HtmlFile2.pro";
              deps = [ kernel UnicodeConverter graphics kernel-network boost ];
            };
            EpubFile = callPackage ./derivation.nix {
              module = "EpubFile";
              version = "1.0.0.0";
              pro = "EpubFile/CEpubFile.pro";
              deps = [ kernel graphics HtmlFile2 ];
            };
            BinDocument = callPackage ./derivation.nix {
              module = "BinDocument";
              version = "1.0.0.0";
              pro = "OOXML/Projects/Linux/BinDocument/BinDocument.pro";
              deps = [ boost ];
            };
            PPTXFormat = callPackage ./derivation.nix {
              module = "PPTXFormatLib";
              version = "1.0.0.0";
              pro = "OOXML/Projects/Linux/PPTXFormatLib/PPTXFormatLib.pro";
              deps = [ boost ];
            };
            Fb2File = callPackage ./derivation.nix {
              module = "Fb2File";
              version = "0.0.0.1";
              pro = "Fb2File/Fb2File.pro";
              deps = [ boost kernel UnicodeConverter graphics ];
            };
            CompoundFile = callPackage ./derivation.nix {
              module = "CompoundFileLib";
              version = "0.0.0.1";
              pro = "Common/cfcpp/cfcpp.pro";
              deps = [ ];
            };
            HtmlRenderer = callPackage ./derivation.nix {
              module = "HtmlRenderer";
              version = "1.0.0.3";
              pro = "HtmlRenderer/htmlrenderer.pro";
              deps = [ kernel UnicodeConverter graphics ];
            };
            XpsFile = callPackage ./derivation.nix {
              module = "XpsFile";
              version = "1.0.0.3";
              pro = "XpsFile/XpsFile.pro";
              deps = [ kernel UnicodeConverter graphics PdfFile ];
            };
            PptFormat = callPackage ./derivation.nix {
              module = "PptFormatLib";
              version = "1.0.0.0";
              pro = "MsBinaryFile/Projects/PPTFormatLib/Linux/PPTFormatLib.pro";
              deps = [ boost ];
            };
            DocxRenderer = callPackage ./derivation.nix {
              module = "DocxRenderer";
              version = "1.0.0.4";
              pro = "DocxRenderer/DocxRenderer.pro";
              deps = [ UnicodeConverter graphics kernel ];
            };
            XlsFormat = callPackage ./derivation.nix {
              module = "XlsFormatLib";
              version = "1.0.0.0";
              pro = "MsBinaryFile/Projects/XlsFormatLib/Linux/XlsFormatLib.pro";
              deps = [ boost ];
            };
            doctrenderer = callPackage ./derivation.nix {
              module = "doctrenderer";
              version = "1.0.0.3";
              pro = "DesktopEditor/doctrenderer/doctrenderer.pro";
              deps = [
                boost
                pkgs.v8
                kernel
                UnicodeConverter
                graphics
                kernel-network
              ];
            };
            DocxFormat = callPackage ./derivation.nix {
              module = "DocxFormatLib";
              version = "1.0.0.0";
              pro = "OOXML/Projects/Linux/DocxFormatLib/DocxFormatLib.pro";
              deps = [ boost ];
            };
            XlsbFormat = callPackage ./derivation.nix {
              module = "XlsbFormatLib";
              version = "1.0.0.0";
              pro = "OOXML/Projects/Linux/XlsbFormatLib/XlsbFormatLib.pro";
              deps = [ boost doctrenderer DocxFormat ];
            };
            allfontsgen = (callPackage ./derivation.nix {
              module = "allfontsgen";
              version = "0.0.0.1";
              pro = "DesktopEditor/AllFontsGen/AllFontsGen.pro";
              deps = [ kernel UnicodeConverter graphics ];
            }).overrideAttrs {
              installPhase = ''
                mkdir -p $out/bin
                mv build/bin/linux_64/allfontsgen $out/bin/
                cp ${pkgs.onlyoffice-documentserver}/var/www/onlyoffice/documentserver/server/FileConverter/bin/icudtl*.dat $out/bin/
              '';
            };
            allthemesgen = (callPackage ./derivation.nix {
              module = "allthemesgen";
              version = "0.0.0.1";
              pro = "DesktopEditor/allthemesgen/allthemesgen.pro";
              deps = [ graphics kernel kernel-network doctrenderer UnicodeConverter ];
            }).overrideAttrs {
              installPhase = ''
                mkdir -p $out/bin
                mv build/bin/linux_64/allthemesgen $out/bin/
                cp ${pkgs.onlyoffice-documentserver}/var/www/onlyoffice/documentserver/server/FileConverter/bin/icudtl*.dat $out/bin/
              '';
            };
            x2t = (callPackage ./derivation.nix {
              module = "x2t";
              version = "0.0.0.1";
              pro = "X2tConverter/build/Qt/X2tConverter.pro";
              deps = [ UnicodeConverter kernel graphics kernel-network cryptopp PdfFile VbaFormat DjVuFile OdfFormat DocFormat TxtXmlFormat RtfFormat EpubFile HtmlFile2 BinDocument PPTXFormat Fb2File CompoundFile HtmlRenderer XpsFile PptFormat DocxRenderer XlsFormat XlsbFormat DocxFormat doctrenderer boost icu ];
            }).overrideAttrs {
              installPhase = ''
                mkdir -p $out/bin
                mv build/bin/linux_64/x2t $out/bin/
                cp ${pkgs.onlyoffice-documentserver}/var/www/onlyoffice/documentserver/server/FileConverter/bin/icudtl*.dat $out/bin/
              '';
            };
            onlyoffice-documentserver = pkgs.callPackage ./onlyoffice.nix { inherit x2t allfontsgen allthemesgen; };
          };
        }
      ) // {
      overlays.default = _: prev: {
        onlyoffice-documentserver = self.packages."${prev.system}".onlyoffice-documentserver;
      };
    };
}

