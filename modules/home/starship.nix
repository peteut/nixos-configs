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
      battery = {
        disabled = false;
        full_symbol = "  ";
        charging_symbol = " ";
        discharging_symbol = "  ";
        unknown_symbol = "  ";
        empty_symbol = "  ";
        display = [
          {
            threshold = 10;
            style = "bold red";
            discharging_symbol = "  ";
          }
          {
            threshold = 20;
            style = "bold yellow";
            discharging_symbol = "  ";
          }
          {
            threshold = 60;
            style = "bold green";
          }
        ];
      };
    };
  };
}
