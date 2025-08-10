{ ... }:
{
  programs.helix.settings = {
    theme = "nord-night";
    keys = {
      normal = {
        up = "no_op";
        down = "no_op";
        left = "no_op";
        right = "no_op";
        pageup = "no_op";
        pagedown = "no_op";
        home = "no_op";
        end = "no_op";
      };
      normal.g = {
        G = "goto_file_end";
        g = "goto_file_start";
      };
      insert = {
        up = "no_op";
        down = "no_op";
        left = "no_op";
        right = "no_op";
        pageup = "no_op";
        pagedown = "no_op";
        home = "no_op";
        end = "no_op";
      };
    };
    editor = {
      trim-trailing-whitespace = true;
      cursor-shape = {
        insert = "bar";
      };
      statusline = {
        left = [ "mode" "spinner" "version-control" ];
        center = [ "file-name" "file-modification-indicator" ];
      };
      lsp = {
        display-inlay-hints = true;
      };
      indent-guides = {
        render = true;
        character = "▏";
        skip-levels = 1;
      };
      end-of-line-diagnostics = "hint";
      inline-diagnostics = {
        cursor-line = "hint";
        other-lines = "hint";
      };
    };
  };
}
