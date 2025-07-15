{ pkgs, stdenv, fetchurl, requireFile, makeDesktopItem }:
# derived from https://github.com/qhga/nix-pianoteq7,
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/audio/pianoteq/default.nix
let
  name = "stage-8";
  pname = "pianoteq-${name}";
  version = "8.1.3";
  lib = pkgs.lib;
  versionForFile = v: builtins.replaceStrings [ "." ] [ "" ] v;
  binName = "pianoteq_stage_linux_v${versionForFile version}.7z";
  # hash = lib.fakeHash;
  hash = "sha256-RgXJfTuUp3O4dYin2GkgvvDwi3Ua1orOOxFRXAKF4PQ=";

  icon = fetchurl {
    name = "pianoteq_icon_128";
    url = "https://www.pianoteq.com/images/logo/pianoteq_icon_128.png";
    hash = "sha256-lO5kz2aIpJ108L9w2BHnRmq6wQP+6rF0lqifgor8xtM=";
  };

  # IMPORTANT: Use the following command to retrive the correct hash.
  # Otherwise the file is not found in the nix store (Add it first ofc)
  # `nix hash file pianoteq_stage_linux_v673.7z`.
  src = requireFile {
    name = binName;
    message = "Download the file from: https://www.modartt.com/download?file=${binName} and add it to the nix store manually: nix store add-file ./${binName}";
    inherit hash;
  };
  archDir = "x86-64bit";

  buildInputs = builtins.attrValues {
    inherit (stdenv.cc.cc) lib;
    inherit (pkgs) alsa-lib freetype;
    inherit (pkgs.xorg) libX11 libXext;
  };
  startupWMClass = "Pianoteq STAGE";
  mainProgram = "Pianoteq 8 STAGE";
in
stdenv.mkDerivation {
  inherit name pname icon src buildInputs;

  unpackPhase = ''
    ${pkgs.p7zip}/bin/7z x $src
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = mainProgram;
      exec = ''"${mainProgram}"'';
      icon = "pianoteq";
      categories = [ " AudioVideo" "Audio" "Recorder" ];
      startupNotify = false;
      inherit startupWMClass;
    })
  ];

  nativeBuildInputs = builtins.attrValues {
    inherit (pkgs) copyDesktopItems autoPatchelfHook makeWrapper;
  };

  # `runHook postInstall` is mandatory otherwise postInstall won't run
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mv -t $out/bin Pianoteq*/${archDir}/*
    for f in $out/bin/Pianoteq*; do
      if [ -x "$f" ] && [ -f "$f" ]; then
        wrapProgram "$f" --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath (buildInputs ++ (builtins.attrValues {
            inherit (pkgs.xorg) libXcursor libXinerama libXrandr;
            inherit (pkgs) libjack2 zlib;
          }))
        }
      fi
    done
    install -Dm 644 ${icon} $out/share/icons/hicolor/128x128/apps/pianoteq.png
    runHook postInstall
  '';
}
