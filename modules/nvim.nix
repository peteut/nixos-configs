{ lib, config, pkgs, nixvim, ... }:
let
  cfg = config.modules.nvim;
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [
    nixvim.nixosModules.nixvim
  ];
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      globals = {
        mapleader = ",";
        maplocalleader = ",";
        autoformat = true;
        markdown_recommended_stle = 0;
        # LazyVim root dir detection
        # Each entry can be:
        # * the name of a detector function like `lsp` or `cwd`
        # * a pattern or array of patterns like `.git` or `lua`.
        # * a function with signature `function(buf) -> string|string[]`
        root_spec = [ "lsp" [ ".git" "lua" ] "cwd" ];
      };
      options = {
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
          # fold = "⸱";
          fold = " ";
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
        opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
        opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
        opt.foldmethod = "indent"
        -- }}}
        -- regex {{{
        vim.keymap.set({ "n", "v" }, "/", "/\\v", { desc = "Sane Regexes" })
        -- }}}
      '';
      extraConfigLua =
        let
          coding = builtins.readFile ./nvim/coding.lua;
          ui = builtins.readFile ./nvim/ui.lua;
          editor = builtins.readFile ./nvim/editor.lua;
          # lsp-keymaps = builtins.readFile ./nvim/plugins/lsp/keymaps.lua;
        in
        ''
          -- coding {{{
          ${coding}
          -- }}}
          -- ui {{{
          ${ui}
          -- }}}
          -- editor {{{
          ${editor}
          -- }}}
        '';
      colorschemes.nord = {
        enable = true;
        contrast = true;
        cursorline_transparent = true;
        italic = true;
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
          action = ''function() vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + 2) end'';
          lua = true;
          options = {
            desc = "Increase window height";
          };
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = ''function() vim.api.nvim_win_set_height(0,  vim.api.nvim_win_get_height(0) - 2) end'';
          lua = true;
          options = {
            desc = "Decrease window height";
          };
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) - 2) end'';
          lua = true;
          options = {
            desc = "Decrease window width";
          };
        }
        {
          mode = "n";
          key = "<C-Right>";
          action = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + 2) end'';
          lua = true;
          options = {
            desc = "Increase window width";
          };
        }
        # }}}
        # mini.bufremove {{{
        {
          mode = "n";
          key = "<leader>bd";
          action = ''
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
          lua = true;
          options = {
            desc = "Delete Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>bD";
          action = ''function() require("mini.bufremove").delete(0, true) end'';
          lua = true;
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
          action = ''function() require("noice").redirect(vim.fn.getcmdline()) end'';
          lua = true;
          options = {
            desc = "Redirect Cmdline";
          };
        }
        {
          mode = "n";
          key = "<leader>snl";
          action = ''function() require("noice").cmd("last") end'';
          lua = true;
          options = {
            desc = "Noice Last Message";
          };
        }
        {
          mode = "n";
          key = "<leader>snh";
          action = ''function() require("noice").cmd("history") end'';
          lua = true;
          options = {
            desc = "Noice History";
          };
        }
        {
          mode = "n";
          key = "<leader>sna";
          action = ''function() require("noice").cmd("all") end'';
          lua = true;
          options = {
            desc = "Noice All";
          };
        }
        {
          mode = "n";
          key = "<leader>snd";
          action = ''function() require("noice").cmd("dismiss") end'';
          lua = true;
          options = {
            desc = "Dismiss All";
          };
        }
        {
          key = "<c-f>";
          action = ''
            function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end
          '';
          lua = true;
          options = {
            desc = "Scroll forward";
            silent = true;
            expr = true;
          };
        }
        {
          key = "<c-b>";
          action = ''function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end
          '';
          lua = true;
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
          action = ''
            function()
              require("neo-tree.command").execute({
                toggle = true, dir = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
              })
            end
          '';
          lua = true;
          options = {
            desc = "Explorer NeoTree (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>fE";
          action = ''
            function() require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() }) end'';
          lua = true;
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
          action = ''function() require("telescope.builtin").buffers({ show_all_buffers = true }) end'';
          lua = true;
          options = {
            desc = "Switch Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>/";
          action = ''
            function()
              require("telescope.builtin").live_grep({
                cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
              })
            end'';
          lua = true;
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
          action = ''
            function()
              require("telescope.builtin").find_files({
                cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
              })
            end'';
          lua = true;
          options = {
            desc = "Find files (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = ''require("telescope.builtin").buffers'';
          lua = true;
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
          action = ''function() require("telescope.builtin").find_files({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          options = {
            desc = "Find Files (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>fr";
          action = ''require("telescope.builtin").oldfiles'';
          lua = true;
          options = {
            desc = "Recent Files";
          };
        }
        {
          mode = "n";
          key = "<leader>fR";
          action = ''function() require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          options = {
            desc = "Recent Files (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>gc";
          action = ''require("telescope.builtin").git_commits'';
          lua = true;
          options = {
            desc = "Git Commits";
          };
        }
        {
          mode = "n";
          key = "<leader>gs";
          action = ''require("telescope.builtin").git_status'';
          lua = true;
          options = {
            desc = "Git Status";
          };
        }
        {
          mode = "n";
          key = "<leader>sa";
          action = ''require("telescope.builtin").autocommands'';
          lua = true;
          options = {
            desc = "Auto Commands";
          };
        }
        {
          mode = "n";
          key = "<leader>sb";
          action = ''require("telescope.builtin").current_buffer_fuzzy_find'';
          lua = true;
          options = {
            desc = "Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>sc";
          action = ''require("telescope.builtin").command_history'';
          lua = true;
          options = {
            desc = "Command History";
          };
        }
        {
          mode = "n";
          key = "<leader>sC";
          action = ''require("telescope.builtin").commands'';
          lua = true;
          options = {
            desc = "Commands";
          };
        }
        {
          mode = "n";
          key = "<leader>sd";
          action = ''function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end'';
          lua = true;
          options = {
            desc = "Document Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>sD";
          action = ''require("telescope.builtin").diagnostics'';
          lua = true;
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
          action = ''
            function()
              require("telescope.builtin").live_grep({
                cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
              })
            end'';
          lua = true;
          options = {
            desc = "Grep (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>sh";
          action = ''require("telescope.builtin").help_tags'';
          lua = true;
          options = {
            desc = "Help Pages";
          };
        }
        {
          mode = "n";
          key = "<leader>sH";
          action = ''require("telescope.builtin").highlights'';
          lua = true;
          options = {
            desc = "Search Highlights";
          };
        }
        {
          mode = "n";
          key = "<leader>sk";
          action = ''require("telescope.builtin").keymaps'';
          lua = true;
          options = {
            desc = "Key Maps";
          };
        }
        {
          mode = "n";
          key = "<leader>sM";
          action = ''require("telescope.builtin").man_pages'';
          lua = true;
          options = {
            desc = "Man Pages";
          };
        }
        {
          mode = "n";
          key = "<leader>sm";
          action = ''require("telescope.builtin").marks'';
          lua = true;
          options = {
            desc = "Jump to Mark";
          };
        }
        {
          mode = "n";
          key = "<leader>so";
          action = ''require("telescope.builtin").vim_options'';
          lua = true;
          options = {
            desc = "Options";
          };
        }
        {
          mode = "n";
          key = "<leader>sR";
          action = ''require("telescope.builtin").resume'';
          lua = true;
          options = {
            desc = "Resume";
          };
        }
        {
          mode = "n";
          key = "<leader>sw";
          action = ''
            function()
              require("telescope.builtin").grep_string({
                cwd = require("null-ls.utils").root_pattern(".git")(vim.loop.cwd())
              })
            end'';
          lua = true;
          options = {
            desc = "Word (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>sW";
          action = ''function() require("telescope.builtin").grep_string({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          options = {
            desc = "Word (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>uC";
          action = ''
            function() require("telescope.builtin").colorscheme({ enable_preview = true }) end'';
          lua = true;
          options = {
            desc = "Colourscheme";
          };
        }
        # }}}
        # Trouble {{{
        {
          mode = "n";
          key = "<leader>xx";
          action = ''function() require("trouble").open("document_diagnostics") end'';
          lua = true;
          options = {
            desc = "Document Diagnostic (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xX";
          action = ''function() require("trouble").open("workspace_diagnostics") end'';
          lua = true;
          options = {
            desc = "Document Diagnostic (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xL";
          action = ''function() require("trouble").open("loclist") end'';
          lua = true;
          options = {
            desc = "Location List (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xQ";
          action = ''function() require("trouble").open("quickfix") end'';
          lua = true;
          options = {
            desc = "Quickfix List (Trouble)";
          };
        }
        {
          mode = "n";
          key = "[q";
          action = ''
            function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.previous({ skip_groups = true, jump = true })
              else
                vim.cmd.cprev()
              end
            end'';
          lua = true;
          options = {
            desc = "Previous Trouble/Quickfix item";
          };
        }
        {
          mode = "n";
          key = "]q";
          action = ''
            function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.next({ skip_groups = true, jump = true })
              else
                vim.cmd.cnext()
              end
            end'';
          lua = true;
          options = {
            desc = "Next Trouble/Quickfix item";
          };
        }
        # }}}
      ];
      plugins = {
        notify = {
          enable = true;
          timeout = 3000;
        };
        treesitter = {
          enable = true;
          indent = true;
        };
        indent-blankline = {
          enable = true;
          indent = {
            char = "│";
          };
          exclude = {
            filetypes = [ "help" "alpha" "dashboard" "neo-tree" "Trouble" "lazy" ];
          };
        };
        noice = {
          enable = true;
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
        telescope = {
          enable = true;
        };
        trouble = {
          enable = true;
          useDiagnosticSigns = true;
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
              rootDir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            ruff-lsp = {
              enable = true;
              rootDir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            gopls = {
              enable = true;
              rootDir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            hls = {
              enable = true;
              cmd = [
                "haskell-language-server-wrapper"
                "--lsp"
              ];
              rootDir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            jsonls = {
              enable = true;
              rootDir = ''require("null-ls.utils").root_pattern(".git")'';
            };
            clangd = {
              enable = true;
            };
            nil_ls = {
              enable = true;
              rootDir = ''require("null-ls.utils").root_pattern("flake.nix", ".git")'';
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
          };
          onAttach = ''
            if client.name == "ruff_lsp" then
              -- disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
            require("lazyvim.plugins.lsp.keymaps").on_attach(client, bufnr)
            -- require("lazyvim.plugins.lsp.format").on_attach(client, bufnr)
            -- vim.keymap.set({ "n", "v" }, "<leader>cf", require("lazyvim.plugins.lsp.format").format, { buffer = bufnr; desc = "Format" })
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
        none-ls = {
          enable = true;
          sources.formatting = {
            black = {
              enable = true;
            };
          };
          rootDir = ''require("null-ls.utils").root_pattern(".git")'';
        };
        cmp-nvim-lsp.enable = true;
        cmp-path.enable = true;
        cmp-buffer.enable = true;
        nvim-cmp = {
          enable = true;
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
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
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
        # mini = {
        #   enable = true;
        #   modules = {
        #     bufremove = { };
        #     pairs = { };
        #     comment = { };
        #   };
        # };
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
          mini-nvim
          noice-nvim
          LazyVim
          bufferline-nvim
          lualine-nvim
          nvim-web-devicons
          nui-nvim
          neo-tree-nvim
          ;
      };
    };
  };
}
