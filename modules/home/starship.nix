{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      shell.disabled = false;
      time.disabled = false;
    };
  };
}
