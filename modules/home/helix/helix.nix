{ pkgsUnstable, ... }:
{
  programs.helix = {
    enable = true;
    package = pkgsUnstable.helix;
  };
}
