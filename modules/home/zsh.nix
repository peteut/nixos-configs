{ ... }:
{
  programs = {
    zsh = {
      enable = false;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "git-prompt"
        ];
      };
    };
    starship = {
      enableZshIntegration = true;
    };
  };
}
