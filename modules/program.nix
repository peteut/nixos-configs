{ ... }:
{
  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
