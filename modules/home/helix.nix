{ ... }:
{
  programs.helix = {
    enable = true;
    extraConfig = ''
      [keys.normal]
      up = "no_op"
      down = "no_op"
      left = "no_op"
      right = "no_op"
      pageup = "no_op"
      pagedown = "no_op"
      home = "no_op"
      end = "no_op"

      [keys.normal.g]
      G = "goto_file_end"
      g = "goto_file_start"

      [keys.insert]
      up = "no_op"
      down = "no_op"
      left = "no_op"
      right = "no_op"
      pageup = "no_op"
      pagedown = "no_op"
      home = "no_op"
      end = "no_op"
    '';
  };
}
