(final: prev:
let
  inherit (builtins) replaceStrings;
  inherit (prev) requireFile;
  version8 = "8.4.3";
  hash = "sha256-fNVHZslILLVDu5z39Mm7WxHjL8A4v0Qa3Mye67Fx3Mg=";
  versionForFile = v: replaceStrings [ "." ] [ "" ] v;
  binName = "pianoteq_stage_linux_v${versionForFile version8}.7z";
in
{
  pianoteq = prev.pianoteq // {
    stage_8 = prev.pianoteq.stage_8.overrideAttrs (old:
      {
        version = version8;
        src = requireFile {
          name = binName;
          message = "Download the file from: https://www.modartt.com/download?file=${binName} and add it to the nix store manually: nix store add-file ./${binName}";
          inherit hash;
        };
      });

  };
})
