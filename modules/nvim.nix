{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    configure = {
      customRC = ''
        set background=dark
        set termguicolors
        set number
      '';
      packages.myVimPackage = {
        start = builtins.attrValues {
          inherit (pkgs.vimPlugins)
            # sane defaults
            vim-sensible
            # fancy status line
            vim-airline
            # themes for status line
            vim-airline-themes
            # nix syntax
            vim-nix
            # git
            vim-fugitive
            # collection of colorschemes
            awesome-vim-colorschemas
            ;
        };
      };
    };
  };
}
