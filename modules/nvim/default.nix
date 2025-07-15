{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.modules.nvim;
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    environment.variables = { EDITOR = "nvim"; };
    programs.nixvim = {
      enable = true;
      globals = {
        mapleader = ",";
        maplocalleader = ",";
        autoformat = true;
        autoformat_autoindent = false;
        autoformat_retab = false;
        autoformat_remove_trailing_spaces = false;
        markdown_recommended_stle = 0;
        # LazyVim root dir detection
        # Each entry can be:
        # * the name of a detector function like `lsp` or `cwd`
        # * a pattern or array of patterns like `.git` or `lua`.
        # * a function with signature `function(buf) -> string|string[]`
        root_spec = [ "lsp" [ ".git" "lua" ] "cwd" ];
      };
      opts = {
        # Turn backup off, since most stuff is in SVN, git etc. anyway...
        backup = false;
        wb = true;
        swapfile = false;
        # autowrite = true; # Enable auto write
        clipboard = "unnamedplus"; # Sync with system clipboard
        completeopt = "menu,menuone,noselect";
        conceallevel = 2; # Hide * markup for bold and italic, but not markers w/ substitutions
        confirm = true; # Confirm to save changes before exiting modified buffer
        cursorline = true; # Enable highlighting of the current line
        expandtab = true; # Use spaces instead of tabs
        formatoptions = "jcroqlnt"; # tcqj
        grepformat = "%f:%l:%c:%m";
        grepprg = "rg --vimgrep";
        ignorecase = true; # Ignore case
        magic = true;
        inccommand = "nosplit"; # preview incremental substitute
        laststatus = 3; # global statusline
        list = true; # Show some invisible characters (tabs...
        mouse = "a"; # Enable mouse mode
        number = true; # Print line number
        pumblend = 10; # Popup blend
        pumheight = 10; # Maximum number of entries in a popup
        relativenumber = true; # Relative line numbers
        scrolloff = 4; # Lines of context
        sessionoptions = [ "buffers" "curdir" "tabpages" "winsize" "help" "globals" "skiprtp" "folds" ];
        shiftround = true; # Round indent
        shiftwidth = 2; # Size of an indent
        showmode = false; # Dont show mode since we have a statusline
        sidescrolloff = 8; # Columns of context
        signcolumn = "yes"; # Always show the signcolumn, otherwise it would shift the text each time
        smartcase = true; # Don't ignore case with capitals
        smartindent = true; # Insert indents automatically
        spelllang = [ "en" ];
        splitbelow = true; # Put new windows below current
        splitkeep = "screen";
        splitright = true; # Put new windows right of current
        tabstop = 2; # Number of spaces tabs count for
        termguicolors = true; # True colour support
        virtualedit = "block"; # Allow cursor to move where there is no text in visual block mode
        # wildmode = "longest:full,full"; # Command-line completion mode
        winminwidth = 5; # Minimum window width
        wrap = false; # Disable line wrap
        fillchars = {
          foldopen = "";
          foldclose = "";
          fold = "⸱";
          foldsep = " ";
          diff = "╱";
          eob = " ";
        };
      };
      extraConfigLuaPre = ''
        -- LazyVim {{{
        require("lazyvim.config.init")
        require("lazyvim.config.autocmds")
        local opt = vim.opt
        opt.shortmess:append({ W = true, I = true, c = true, C = true })
        if vim.fn.has("nvim-0.10") == 1 then
        opt.smoothscroll = true
        end
        vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
        -- Folding
        opt.foldlevel = 99
        -- opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
        -- opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
        opt.foldmethod = "indent"
        -- }}}
        -- regex {{{
        vim.keymap.set({ "n", "v" }, "/", "/\\v", { desc = "Sane Regexes" })
        -- }}}
      '';
      extraConfigLua =
        let
          ui = builtins.readFile ./ui.lua;
        in
        ''
          -- ui {{{
          ${ui}
          -- }}}
        '';
      colorschemes.nord = {
        enable = true;
        # cursorline_transparent = true;
        settings = {
          italic = true;
          contrast = true;
        };
      };
      globals = {
        neo_tree_remove_legacy_commands = true;
      };
      keymaps = [
        # stop using arrow keys {{{
        {
          key = "<left>";
          action = "<nop>";
        }
        {
          key = "<up>";
          action = "<nop>";
        }
        {
          key = "<down>";
          action = "<nop>";
        }
        {
          key = "<right>";
          action = "<nop>";
        }
        # }}}
        # better up/down {{{
        {
          mode = "n";
          key = "j";
          action = ''v:count == 0 ? "gj" : "j"'';
          options = {
            expr = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "k";
          action = ''v:count == 0 ? "gk" : "k"'';
          options = {
            expr = true;
            silent = true;
          };
        }
        # }}}
        # Move to window using the <ctrl> hjkl keys {{{
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options = {
            desc = "Go to left window";
          };
        }
        {
          mode = "t";
          key = "<C-h>";
          action = "<C-\\><C-N><C-w>h";
          options = {
            desc = "Go to left window";
          };
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options = {
            desc = "Go to lower window";
          };
        }
        {
          mode = "t";
          key = "<C-j>";
          action = "<C-\\><C-N><C-w>j";
          options = {
            desc = "Go to lower window";
          };
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options = {
            desc = "Go to upper window";
          };
        }
        {
          mode = "t";
          key = "<C-k>";
          action = "<C-\\><C-N><C-w>k";
          options = {
            desc = "Go to upper window";
          };
        }
        {
          mode = "t";
          key = "<C-k>";
          action = "<C-\\><C-N><C-w>k";
          options = {
            desc = "Go to upper window";
          };
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options = {
            desc = "Go to right window";
          };
        }
        {
          mode = "t";
          key = "<C-l>";
          action = "<C-\\><C-N><C-w>l";
          options = {
            desc = "Go to right window";
          };
        }
        # }}}
        # Resize window using <ctrl> arrow keys {{{
        {
          mode = "n";
          key = "<C-Up>";
          action.__raw = ''function() vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + 2) end'';
          options = {
            desc = "Increase window height";
          };
        }
        {
          mode = "n";
          key = "<C-Down>";
          action.__raw = ''function() vim.api.nvim_win_set_height(0,  vim.api.nvim_win_get_height(0) - 2) end'';
          options = {
            desc = "Decrease window height";
          };
        }
        {
          mode = "n";
          key = "<C-Left>";
          action.__raw = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) - 2) end'';
          options = {
            desc = "Decrease window width";
          };
        }
        {
          mode = "n";
          key = "<C-Right>";
          action.__raw = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + 2) end'';
          options = {
            desc = "Increase window width";
          };
        }
        # }}}
        # Move lines {{{
        {
          mode = "n";
          key = "<A-j>";
          action = "<cmd>m .+1<cr>==";
          options = {
            desc = "Move down";
          };
        }
        {
          mode = "n";
          key = "<A-k>";
          action = "<cmd>m .-2<cr>==";
          options = { desc = "Move up"; };
        }
        {
          mode = "i";
          key = "<A-j>";
          action = "<esc><cmd>m .+1<cr>==gi";
          options = { desc = "Move down"; };
        }
        {
          mode = "i";
          key = "<A-k>";
          action = "<esc><cmd>m .-2<cr>==gi";
          options = { desc = "Move up"; };
        }
        {
          mode = "v";
          key = "<A-j>";
          action = ":m '>+1<cr>gv=gv";
          options = { desc = "Move down"; };
        }
        {
          mode = "v";
          key = "<A-k>";
          action = ":m '<-2<cr>gv=gv";
          options = { desc = "Move up"; };
        }
        # }}}
        # buffer remove {{{
        {
          mode = "n";
          key = "<leader>bd";
          action.__raw = ''
            function()
              local bd = require("mini.bufremove").delete
              if vim.bo.modified then
                local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
                if choice == 1 then -- Yes
                  vim.cmd.write()
                  bd(0)
                elseif choice == 2 then -- No
                  bd(0, true)
                end
              else
                bd(0)
              end
            end'';
          options = {
            desc = "Delete Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>bD";
          action.__raw = ''function() require("mini.bufremove").delete(0, true) end'';
          options = {
            desc = "Delete Buffer (Force)";
          };
        }
        # }}}
        # buffers {{{
        {
          mode = "n";
          key = "<S-h>";
          action = "<cmd>BufferLineCyclePrev<cr>";
          options = {
            desc = "Pref buffer";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<S-l>";
          action = "<cmd>BufferLineCycleNext<cr>";
          options = {
            desc = "Next buffer";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "[b";
          action = "<S-h>";
          options = {
            desc = "Prev buffer";
            remap = true;
          };
        }
        {
          mode = "n";
          key = "b]";
          action = "<S-l>";
          options = {
            desc = "Next buffer";
            remap = true;
          };
        }
        # }}}
        # Clear search with <esc> {{{
        {
          mode = "n";
          key = "<esc>";
          action = "<cmd>noh<cr><esc>";
          options = {
            desc = "Escape and clear hlsearch";
            silent = true;
          };
        }
        {
          mode = "i";
          key = "<esc>";
          action = "<cmd>noh<cr><esc>";
          options = {
            desc = "Escape and clear hlsearch";
            silent = true;
          };
        }
        # }}}
        # search word under cursor {{{
        {
          mode = "n";
          key = "gw";
          action = "*N";
          options = {
            desc = "Search word under cursor";
          };
        }
        {
          mode = "v";
          key = "gw";
          action = "*N";
          options = {
            desc = "Search word under cursor";
          };
        }
        # }}}
        #  {{{
        {
          key = "n";
          action = '''Nn'[v:searchforward]'';
          options = {
            expr = true;
            desc = "Next search result";
          };
        }
        {
          key = "N";
          action = '''nN'[v:searchforward]'';
          options = {
            expr = true;
            desc = "Prev search result";
          };
        }
        # }}}
        # add undo break-pints {{{
        {
          mode = "n";
          key = ",";
          action = ",<c-g>u";
        }
        {
          mode = "i";
          key = ".";
          action = ".<c-g>u";
        }
        {
          mode = "i";
          key = ";";
          action = ";<c-g>u";
        }
        # }}}
        # save file {{{
        {
          key = "<C-s>";
          action = "<cmd>w<cr><esc>";
          options = {
            desc = "Save file";
          };
        }
        # }}}
        # better indenting {{{
        {
          mode = "v";
          key = "<";
          action = "<gv";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
        }
        # }}}
        # new file {{{
        {
          mode = "n";
          key = "<leader>fn";
          action = "<cmd>enew<cr>";
          options = {
            desc = "New File";
          };
        }
        # }}}
        # toggle options {{{
        # TODO: migrate keymaps
        # }}}
        # quit {{{
        {
          mode = "n";
          key = "<leader>qq";
          action = "<cmd>qa<cr>";
          options = {
            desc = "Quit all";
          };
        }
        # }}}
        # Hightlight under cursor {{{
        {
          mode = "n";
          key = "<leader>ui";
          action = ''vim.show_pos'';
          options = {
            desc = "Inspect Pos";
          };
        }
        # }}}
        # terminal {{{
        # TODO: floating terminal?
        {
          mode = "t";
          key = "<esc><esc>";
          action = "<c-\\><c-n>";
          options = {
            desc = "Enter Normal Mode";
          };
        }
        # }}}
        # window {{{
        {
          mode = "n";
          key = "<leader>ww";
          action = "<C-W>p";
          options = {
            desc = "Other Window";
          };
        }
        {
          mode = "n";
          key = "<leader>wd";
          action = "<C-W>c";
          options = {
            desc = "Delete Window";
          };
        }
        {
          mode = "n";
          key = "<leader>w-";
          action = "<C-W>s";
          options = {
            desc = "Split Window Below";
          };
        }
        {
          mode = "n";
          key = "<leader>w|";
          action = "<C-W>v";
          options = {
            desc = "Split Window Right";
          };
        }
        {
          mode = "n";
          key = "<leader>-";
          action = "<C-W>s";
          options = {
            desc = "Split Window Below";
          };
        }
        {
          mode = "n";
          key = "<leader>|";
          action = "<C-W>v";
          options = {
            desc = "Split Window Right";
          };
        }
        # }}}
        # tabs {{{
        {
          mode = "n";
          key = "<leader><tab>l";
          action = "<cmd>tablast<cr>";
          options = {
            desc = "Last Tab";
          };
        }
        {
          mode = "n";
          key = "<leader><tab>f";
          action = "<cmd>tabfirst<cr>";
          options = {
            desc = "First Tab";
          };
        }
        {
          mode = "n";
          key = "<leader><tab><tab>";
          action = "<cmd>tabnew<cr>";
          options = {
            desc = "New Tab";
          };
        }
        {
          mode = "n";
          key = "<leader><tab>]";
          action = "<cmd>tabnext<cr>";
          options = {
            desc = "Next Tab";
          };
        }
        {
          mode = "n";
          key = "<leader><tab>d";
          action = "<cmd>tabclose<cr>";
          options = {
            desc = "Close Tab";
          };
        }
        {
          mode = "n";
          key = "<leader><tab>[";
          action = "<cmd>tabprevious<cr>";
          options = {
            desc = "Previous Tab";
          };
        }
        # }}}
        # {{{
        {
          mode = "n";
          key = "<leader>xl";
          action = "<cmd>lopen<cr>";
          options = {
            desc = "Location List";
          };
        }
        {
          mode = "n";
          key = "<leader>xq";
          action = "<cmd>copen<cr>";
          options = {
            desc = "Quickfix List";
          };
        }
        # }}}
        # bufferline {{{
        {
          mode = "n";
          key = "<leader>bp";
          action = "<cmd>BufferLineTogglePin<cr>";
          options = {
            desc = "Toggle pin";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bP";
          action = "<cmd>BufferLineGroupClose ungrouped<cr>";
          options = {
            desc = "Delete non-pinned buffers";
            silent = true;
          };
        }
        # }}}
        # noicer ui {{{
        {
          mode = "c";
          key = "<S-Enter>";
          action.__raw = ''function() require("noice").redirect(vim.fn.getcmdline()) end'';
          options = {
            desc = "Redirect Cmdline";
          };
        }
        {
          mode = "n";
          key = "<leader>snl";
          action.__raw = ''function() require("noice").cmd("last") end'';
          options = {
            desc = "Noice Last Message";
          };
        }
        {
          mode = "n";
          key = "<leader>snh";
          action.__raw = ''function() require("noice").cmd("history") end'';
          options = {
            desc = "Noice History";
          };
        }
        {
          mode = "n";
          key = "<leader>sna";
          action.__raw = ''function() require("noice").cmd("all") end'';
          options = {
            desc = "Noice All";
          };
        }
        {
          mode = "n";
          key = "<leader>snd";
          action.__raw = ''function() require("noice").cmd("dismiss") end'';
          options = {
            desc = "Dismiss All";
          };
        }
        {
          key = "<c-f>";
          action.__raw = ''
            function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end
          '';
          options = {
            desc = "Scroll forward";
            silent = true;
            expr = true;
          };
        }
        {
          key = "<c-b>";
          action.__raw = ''function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end
            '';
          options = {
            desc = "Scroll backward";
            silent = true;
            expr = true;
          };
        }
        # }}}
        # file explorer {{{
        {
          mode = "n";
          key = "<leader>fe";
          action.__raw = ''
            function()
            require("neo-tree.command").execute({
              toggle = true, dir = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
            })
            end
          '';
          options = {
            desc = "Explorer NeoTree (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>fE";
          action.__raw = ''
            function() require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() }) end'';
          options = {
            desc = "Explorer NeoTree (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "<leader>fe";
          options = {
            desc = "Explorer NeoTree (root dir)";
            remap = true;
          };
        }
        {
          mode = "n";
          key = "<leader>E";
          action = "<leader>fE";
          options = {
            desc = "Explorer NeoTree (cwd)";
            remap = true;
          };
        }
        # }}}
        # Telescope {{{
        {
          mode = "n";
          key = "<leader>,";
          action.__raw = ''function() require("telescope.builtin").buffers({ show_all_buffers = true }) end'';
          options = {
            desc = "Switch Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>/";
          action.__raw = ''
            function()
            require("telescope.builtin").live_grep({
              cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
            })
            end'';
          options = {
            desc = "Grep (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>:";
          action = "<cmd>Telescope command_history<cr>";
          options = {
            desc = "Command History";
          };
        }
        {
          mode = "n";
          key = "<leader><space>";
          action.__raw = ''
            function()
            require("telescope.builtin").find_files({
              cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
            })
            end'';
          options = {
            desc = "Find files (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action.__raw = ''require("telescope.builtin").buffers'';
          options = {
            desc = "Buffers";
          };
        }
        {
          mode = "n";
          key = "<leader>ff";
          action = ''<leader><space>'';
          options = {
            remap = true;
            desc = "Find files (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>fF";
          action.__raw = ''function() require("telescope.builtin").find_files({ cwd = vim.loop.cwd() }) end'';
          options = {
            desc = "Find Files (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>fr";
          action.__raw = ''require("telescope.builtin").oldfiles'';
          options = {
            desc = "Recent Files";
          };
        }
        {
          mode = "n";
          key = "<leader>fR";
          action.__raw = ''function() require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() }) end'';
          options = {
            desc = "Recent Files (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>gc";
          action.__raw = ''require("telescope.builtin").git_commits'';
          options = {
            desc = "Git Commits";
          };
        }
        {
          mode = "n";
          key = "<leader>gs";
          action.__raw = ''require("telescope.builtin").git_status'';
          options = {
            desc = "Git Status";
          };
        }
        {
          mode = "n";
          key = "<leader>sa";
          action.__raw = ''require("telescope.builtin").autocommands'';
          options = {
            desc = "Auto Commands";
          };
        }
        {
          mode = "n";
          key = "<leader>sb";
          action.__raw = ''require("telescope.builtin").current_buffer_fuzzy_find'';
          options = {
            desc = "Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>sc";
          action.__raw = ''require("telescope.builtin").command_history'';
          options = {
            desc = "Command History";
          };
        }
        {
          mode = "n";
          key = "<leader>sC";
          action.__raw = ''require("telescope.builtin").commands'';
          options = {
            desc = "Commands";
          };
        }
        {
          mode = "n";
          key = "<leader>sd";
          action.__raw = ''function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end'';
          options = {
            desc = "Document Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>sD";
          action.__raw = ''require("telescope.builtin").diagnostics'';
          options = {
            desc = "Workspace Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>sg";
          action = "<leader>/";
          options = {
            remap = true;
            desc = "Grep (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>sG";
          action.__raw = ''
            function()
            require("telescope.builtin").live_grep({
              cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
            })
            end'';
          options = {
            desc = "Grep (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>sh";
          action.__raw = ''require("telescope.builtin").help_tags'';
          options = {
            desc = "Help Pages";
          };
        }
        {
          mode = "n";
          key = "<leader>sH";
          action.__raw = ''require("telescope.builtin").highlights'';
          options = {
            desc = "Search Highlights";
          };
        }
        {
          mode = "n";
          key = "<leader>sk";
          action.__raw = ''require("telescope.builtin").keymaps'';
          options = {
            desc = "Key Maps";
          };
        }
        {
          mode = "n";
          key = "<leader>sM";
          action.__raw = ''require("telescope.builtin").man_pages'';
          options = {
            desc = "Man Pages";
          };
        }
        {
          mode = "n";
          key = "<leader>sm";
          action.__raw = ''require("telescope.builtin").marks'';
          options = {
            desc = "Jump to Mark";
          };
        }
        {
          mode = "n";
          key = "<leader>so";
          action.__raw = ''require("telescope.builtin").vim_options'';
          options = {
            desc = "Options";
          };
        }
        {
          mode = "n";
          key = "<leader>sR";
          action.__raw = ''require("telescope.builtin").resume'';
          options = {
            desc = "Resume";
          };
        }
        {
          mode = "n";
          key = "<leader>sw";
          action.__raw = ''
            function()
            require("telescope.builtin").grep_string({
              cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
            })
            end'';
          options = {
            desc = "Word (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>sW";
          action.__raw = ''function() require("telescope.builtin").grep_string({ cwd = vim.loop.cwd() }) end'';
          options = {
            desc = "Word (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>uC";
          action.__raw = ''
            function() require("telescope.builtin").colorscheme({ enable_preview = true }) end'';
          options = {
            desc = "Colourscheme";
          };
        }
        # }}}
        # Trouble {{{
        {
          mode = "n";
          key = "<leader>xx";
          action.__raw = ''function() require("trouble").open("document_diagnostics") end'';
          options = {
            desc = "Document Diagnostic (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xX";
          action.__raw = ''function() require("trouble").open("workspace_diagnostics") end'';
          options = {
            desc = "Document Diagnostic (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xL";
          action.__raw = ''function() require("trouble").open("loclist") end'';
          options = {
            desc = "Location List (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xQ";
          action.__raw = ''function() require("trouble").open("quickfix") end'';
          options = {
            desc = "Quickfix List (Trouble)";
          };
        }
        {
          mode = "n";
          key = "[q";
          action.__raw = ''
            function()
            local trouble = require("trouble")
            if trouble.is_open() then
            trouble.previous({ skip_groups = true, jump = true })
            else
            vim.cmd.cprev()
            end
            end'';
          options = {
            desc = "Previous Trouble/Quickfix item";
          };
        }
        {
          mode = "n";
          key = "]q";
          action.__raw = ''
            function()
            local trouble = require("trouble")
            if trouble.is_open() then
            trouble.next({ skip_groups = true, jump = true })
            else
            vim.cmd.cnext()
            end
            end'';
          options = {
            desc = "Next Trouble/Quickfix item";
          };
        }
        # }}}
      ];
      plugins = {
        notify = {
          enable = true;
          settings.timeout = 3000;
        };
        treesitter = {
          settings = {
            enable = true;
            indent = true;
          };
        };
        indent-blankline = {
          enable = true;
          settings = {
            indent = {
              char = "│";
            };
            exclude = {
              filetypes = [ "help" "alpha" "dashboard" "neo-tree" "Trouble" "lazy" ];
            };
          };
        };
        noice = {
          enable = true;
          settings = {
            lsp = {
              override = {
                "vim.lsp.util.convert_input_to_markdown_lines" = true;
                "vim.lsp.util.stylize_markdown" = true;
                "cmp.entry.get_documentation" = true;
              };
            };
            presets = {
              bottom_search = true;
              command_palette = true;
              long_message_to_split = true;
              inc_rename = true;
            };
            routes = [{
              filter = {
                event = "msg_show";
                find = "%d+L, %d+B";
              };
              view = "mini";
            }];
          };
        };
        telescope = {
          enable = true;
        };
        trouble = {
          enable = true;
        };
        which-key = {
          enable = true;
          # registrations = {
          #   "g" = "+goto";
          #   "gz" = "+surround";
          #   "]" = "+next";
          #   "[" = "+prev";
          #   "<leader><tab>" = "+tabs";
          #   "<leader>b" = "+buffer";
          #   "<leader>c" = "+code";
          #   "<leader>f" = "+file/find";
          #   "<leader>g" = "+git";
          #   "<leader>gh" = "+hunks";
          #   "<leader>q" = "+quit/session";
          #   "<leader>s" = "+search";
          #   "<leader>u" = "+ui";
          #   "<leader>w" = "+windows";
          #   "<leader>x" = "+diagnostics/quickfix";
          # };
        };
        nix.enable = true;
        lsp = {
          enable = true;
          servers = {
            pyright = {
              enable = true;
              onAttach = {
                function = ''
                  require("lazyvim.plugins.lsp.keymaps").on_attach(client, bufnr)
                '';
                override = true;
              };
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            ruff = {
              enable = true;
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            gopls = {
              enable = true;
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            hls = {
              enable = true;
              installGhc = false;
              cmd = [
                "haskell-language-server-wrapper"
                "--lsp"
              ];
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            jsonls = {
              enable = true;
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            clangd = {
              enable = true;
            };
            nil_ls = {
              enable = true;
              settings.root_dir = ''require("null-ls.utils").root_pattern("flake.nix", ".git")'';
              extraOptions = {
                settings = {
                  nil = {
                    formatting = {
                      command = [ "nixpkgs-fmt" ];
                    };
                    nix = {
                      binary = "nix";
                      flake = {
                        autoEvalInputs = true;
                        nixpkgsInputName = "nixpkgs";
                      };
                    };
                  };
                };
              };
            };
            vhdl_ls = {
              enable = true;
              filetypes = [ "vhd" "vhdl" ];
              settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
          };
          onAttach = ''
            if client.name == "ruff" then
              -- disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
            vim.keymap.set({ "n", "v" }, "<leader>cf", require("lazyvim.util").format, { buffer = bufnr; desc = "Format" })
          '';
          keymaps = {
            lspBuf = {
              # TODO: cannot use function() for action
              "gd" = {
                action = "definition";
                desc = "Goto Definition";
              };
              "gr" = { action = "references"; desc = "References"; };
              "gD" = { action = "declaration"; desc = "Goto Declaration"; };
              # "gI" = "implementations";
              # "gy" = "type_definitions";
              "K" = { action = "hover"; desc = "Hover"; };
              "gK" = {
                action = "signature_help";
                desc = "Signature Help";
              };
              "<leader>ca" = {
                action = "code_action";
                desc = "Code Action";
              };
            };
          };
        };
        # lsp-format = {
        #   enable = true;
        #   lspServersToEnable = [
        #     "gopls"
        #   ];
        # };
        none-ls = {
          enable = true;
          sources.formatting = {
            black = {
              enable = true;
            };
          };
          settings.root_dir = ''require("null-ls.utils").root_pattern(".git")'';
        };
        cmp-nvim-lsp.enable = true;
        cmp-path.enable = true;
        cmp-buffer.enable = true;
        cmp = {
          enable = true;
          settings = {
            mapping = {
              "<C-n>" = ''cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })'';
              "<C-p>" = ''cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })'';
              "<C-b>" = ''cmp.mapping.scroll_docs(-4)'';
              "<C-f>" = ''cmp.mapping.scroll_docs(4)'';
              "<C-Space>" = ''cmp.mapping.complete()'';
              "<C-e>" = ''cmp.mapping.abort()'';
              "<CR>" = ''cmp.mapping.confirm({ select = true })'';
              "<S-CR>" = ''
                cmp.mapping.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = true,
                })'';
              "<C-CR" = ''
                function(fallback)
                cmp.abort()
                fallback()
                end'';
            };
            # sources = [
            #   { name = "nvim_lsp"; }
            #   { name = "buffer"; }
            #   { name = "path"; }
            # ];
            formatting.format = ''
              function(_, item)
              local icons = require("lazyvim.config").icons.kinds
              if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
              end
              return item
              end
            '';
          };
        };
        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            pairs = { };
            comment = { };
            bufremove = { };
            indentscope = {
              symbol = "|";
              options = { try_as_boarder = true; };
            };
            trailspace = { };
            surround = {
              mappings = {
                add = "gsa";
                delete = "gsd";
                find = "gsf";
                find_left = "gsF";
                highlight = "gsh";
                replace = "gsr";
                update_n_lines = "gsn";
              };
            };
            icons = { };
          };
        };
        lualine = {
          # WIP, migrate from ui.lua
          enable = false;
          settings = {
            extensions = [ "neo-tree" ];
            sections = {
              lualine_a = [ "mode" ];
              lualine_b = [ "branch" ];
              lualine_c = [
                "diagnostics"
                {
                  name = "filetype";
                  padding = {
                    left = 1;
                    right = 0;
                  };
                  separator = {
                    left = "";
                    right = "";
                  };
                  extraConfig = {
                    icon_only = true;
                  };
                }
                {
                  name = "filename";
                  extraConfig = {
                    path = 1;
                  };
                }
                {
                  name = ''
                    function() return require("nvim-navic").get_location() end
                  '';
                  extraConfig = {
                    cond = ''
                      function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end
                    '';
                  };
                }
              ];
            };
            globalstatus = true;
            icons_enabled = true;
            disabled_filetypes.statusline = [ "dashboard" "alpha" ];
          };
        };
        neo-tree = {
          enable = true;
          enableGitStatus = true;
          enableModifiedMarkers = true;
          retainHiddenRootIndent = true;
          filesystem = {
            filteredItems = {
              visible = true;
            };
            followCurrentFile.enabled = true;
            hijackNetrwBehavior = "open_default";
            useLibuvFileWatcher = true;
          };
          defaultComponentConfigs = {
            indent = {
              expanderCollapsed = "";
              expanderExpanded = "";
            };
          };
        };
      };
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          lazygit
          fd
          ripgrep
          nixpkgs-fmt
          ;
      };
      extraPlugins = builtins.attrValues {
        inherit (pkgs.vimPlugins)
          lazy-nvim
          vim-eunuch
          dressing-nvim
          noice-nvim
          LazyVim
          bufferline-nvim
          lualine-nvim
          nui-nvim
          ;
      };
    };
  };
}
