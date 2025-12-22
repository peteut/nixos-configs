{ pkgs, username, ... }:
let inherit (builtins) attrValues;
in
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Alain Péteut";
          email = "alain.peteut@spacetek.ch";
        };
        init.defaultBranch = "main";
        core.autocrlf = "input";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        pull.ff = "only";
        color.ui = true;
        url = {
          "git@github.com:".insteadOf = "https://github.com/";
          "git@gitlab.spacetek.ch:".insteadOf = "https://gitlab.spacetek.ch/";
        };
        core.excludesFile = "/home/${username}/.config/git/.gitignore";
      };
    };
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = false;
        diff-so-fancy = true;
        navigate = true;
      };
    };
  };


  home.packages = attrValues { inherit (pkgs) gh; };
}
