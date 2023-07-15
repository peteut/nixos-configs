{ pkgs, stdenv, fetchurl, requireFile, makeDesktopItem }:
# derived from https://github.com/qhga/nix-pianoteq7
let
  pname = "pianoteq";
  version = "6.7.3";
  name = "${pname}-${version}";
  lib = pkgs.lib;
  binName = "pianoteq_stage_linux_v" + (lib.concatStrings (builtins.filter (s: s != ".") (lib.splitString "." version))) + ".7z";
  sha256 = "sha256-XoZE/w3VqfRgJsfXzhNgrD54GwR+TZzhB5tD69uEwEs=";

  icon = fetchurl {
    name = "pianoteq_icon_128";
    url = "https://www.pianoteq.com/images/logo/pianoteq_icon_128.png";
    sha256 = "sha256-lO5kz2aIpJ108L9w2BHnRmq6wQP+6rF0lqifgor8xtM=";
  };

  # IMPORTANT: Use the following command to retrive the correct hash.
  # Otherwise the file is not found in the nix store (Add it first ofc)
  # `nix hash file pianoteq_stage_linux_v673.7z`.
  src = requireFile {
    name = binName;
    message = "Download the file from: https://www.modartt.com/download?file=${binName} and add it to the nix store manually: nix-store --add-fixed sha256 ./${binName}";
    inherit sha256;
  };
in
stdenv.mkDerivation {
  inherit name icon src;

  desktopItems = [
    (makeDesktopItem {
      name = "${pname}6";
      desktopName = "Pianoteq 6";
      exec = "${pname}6";
      icon = "pianoteq_icon_128";
    })
  ];

  nativeBuildInputs = builtins.attrValues {
    inherit (pkgs) p7zip copyDesktopItems autoPatchelfHook;
  };

  buildInputs = builtins.attrValues {
    inherit (pkgs) alsa-lib freetype libjack2 lv2;
    inherit (pkgs.xorg) libX11 libXext;
    inherit (stdenv.cc.cc) lib;
  };

  unpackCmd = "7z x ${src}";

  # `runHook postInstall` is mandatory otherwise postInstall won't run
  installPhase = ''
    install -Dm 755 amd64/Pianoteq\ 6\ STAGE $out/bin/${pname}6
    install -Dm 755 amd64/Pianoteq\ 6\ STAGE.lv2/Pianoteq_6_STAGE.so \
      $out/lib/lv2/Pianoteq\ 6\ STAGE.lv2/Pianoteq_6.so
    cd amd64/Pianoteq\ 6\ STAGE.lv2/
    for i in *.ttl; do
      install -D "$i" "$out/lib/lv2/Pianoteq 6 STAGE.lv2/$i"
    done
    runHook postInstall
  '';

  # Runs copyDesktopItems hook.
  # Alternatively call copyDesktopItems manually in installPhase/fixupPhase
  postInstall = ''
    install -Dm 444 ${icon} $out/share/icons/hicolor/128x128/apps/pianoteq_icon_128.png
  '';
}
