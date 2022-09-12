{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    configure = {
      customRC = builtins.readFile ./vimrc;
      packages.myVimPackage = {
        start = builtins.attrValues {
          inherit (pkgs.vimPlugins)
            # fancy status line
            vim-airline
            # themes for status line
            vim-airline-themes
            # sugar for shell commands
            vim-eunuch
            # comment stuff out
            vim-commentary
            # nix syntax
            vim-nix
            # git
            vim-fugitive
            # tagbar
            tagbar
            # languageserver
            ale
            # Go
            vim-go
            # Autocompleteion
            deoplete-nvim
            # Bitbake
            bitbake-vim
            # collection of colorschemes
            awesome-vim-colorschemes;
        };
      };
    };
  };
}
