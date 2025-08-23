{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      shell.disabled = false;
      time = {
        disabled = false;
        time_format = "%c";
      };
      hostname = {
        disabled = false;
        ssh_only = false;
      };
    };
  };
}
