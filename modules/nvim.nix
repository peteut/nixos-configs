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
      extraConfigLuaPre = ''
        -- LazyVim {{{
        require("lazyvim.config.options")
        require("lazyvim.config.autocmds")
        -- }}}

        vim.g.mapleader = ","
        vim.g.maplocalleader = ","

        -- Files, backup and undo {{{
        -- Turn backup off, since most stuff is in SVN, git etc. anyway...
        vim.o.nobackup = true
        vim.o.nowb = true
        vim.o.noswapfile = true
        -- }}}
        -- regex {{{
        -- For regular expressions turn magic on
        vim.o.magic = true
        vim.keymap.set({ "n", "v" }, "/", "/\\v", { desc = "Sane Regexes" })
        -- }}}
      '';
      extraConfigLua =
        let
          coding = builtins.readFile ./nvim/coding.lua;
          ui = builtins.readFile ./nvim/ui.lua;
          editor = builtins.readFile ./nvim/editor.lua;
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

          find_git_root_opts = function()
            local function is_git_repo()
              vim.fn.system("git rev-parse --is-inside-work-tree")
              return vim.v.shell_error == 0
            end
            local function get_git_root()
              local dot_git_path = vim.fn.finddir(".git", ".;")
              return vim.fn.fnamemodify(dot_git_path, ":h")
            end
            local opts = {}
            if is_git_repo() then
              opts = {
                cwd = get_git_root(),
              }
            end
            return opts
          end
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
      maps = {
        # stop using arrow keys {{{
        normalVisualOp."<left>" = "<nop>";
        normalVisualOp."<up>" = "<nop>";
        normalVisualOp."<down>" = "<nop>";
        normalVisualOp."<right>" = "<nop>";
        # }}}
        # better up/down {{{
        normal."j" = {
          action = ''v:count == 0 ? "gj" : "j"'';
          expr = true;
          silent = true;
        };
        normal."k" = {
          action = ''v:count == 0 ? "gk" : "k"'';
          expr = true;
          silent = true;
        };
        # }}}
        # Move to window using the <ctrl> hjkl keys {{{
        normal."<C-h>" = {
          action = "<C-w>h";
          desc = "Go to left window";
        };
        terminal."<C-h>" = "<C-\\><C-N><C-w>h";
        normal."<C-j>" = {
          action = "<C-w>j";
          desc = "Go to lower window";
        };
        terminal."<C-j>" = "<C-\\><C-N><C-w>j";
        normal."<C-k>" = {
          action = "<C-w>k";
          desc = "Go to upper window";
        };
        terminal."<C-k>" = "<C-\\><C-N><C-w>k";
        normal."<C-l>" = {
          action = "<C-w>l";
          desc = "Go to right window";
        };
        terminal."<C-l>" = "<C-\\><C-N><C-w>l";
        # }}}
        # Resize window using <ctrl> arrow keys {{{
        normal."<C-Up>" = {
          action = ''function() vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + 2) end'';
          lua = true;
          desc = "Increase window height";
        };
        normal."<C-Down>" = {
          action = ''function() vim.api.nvim_win_set_height(0,  vim.api.nvim_win_get_height(0) - 2) end'';
          lua = true;
          desc = "Decrease window height";
        };
        normal."<C-Left>" = {
          action = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) - 2) end'';
          lua = true;
          desc = "Decrease window width";
        };
        normal."<C-Right>" = {
          action = ''function() vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + 2) end'';
          lua = true;
          desc = "Increase window width";
        };
        # }}}
        # mini.bufremove {{{
        normal."<leader>bd" = {
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
          desc = "Delete Buffer";
        };
        normal."<leader>bD" = {
          action = ''function() require("mini.bufremove").delete(0, true) end'';
          lua = true;
          desc = "Delete Buffer (Force)";
        };
        # }}}
        # buffers {{{
        normal."<S-h>" = {
          action = "<cmd>BufferLineCyclePrev<cr>";
          silent = true;
          desc = "Pref buffer";
        };
        normal."<S-l>" = {
          action = "<cmd>BufferLineCycleNext<cr>";
          silent = true;
          desc = "Next buffer";
        };
        normal."[b" = {
          action = "<S-h>";
          remap = true;
          desc = "Prev buffer";
        };
        normal."b]" = {
          action = "<S-l>";
          remap = true;
          desc = "Next buffer";
        };
        # }}}
        # Clear search with <esc> {{{
        normal."<esc>" = {
          action = "<cmd>noh<cr><esc>";
          desc = "Escape and clear hlsearch";
          silent = true;
        };
        insert."<esc>" = {
          action = "<cmd>noh<cr><esc>";
          desc = "Escape and clear hlsearch";
          silent = true;
        };
        # }}}
        # search word under cursor {{{
        normal."gw" = {
          action = "*N";
          desc = "Search word under cursor";
        };
        visual."gw" = {
          action = "*N";
          desc = "Search word under cursor";
        };
        # }}}
        #  {{{
        normalVisualOp."n" = {
          action = '''Nn'[v:searchforward]'';
          expr = true;
          desc = "Next search result";
        };
        normalVisualOp."N" = {
          action = '''nN'[v:searchforward]'';
          expr = true;
          desc = "Prev search result";
        };
        # }}}
        # add undo break-pints {{{
        insert."," = {
          action = ",<c-g>u";
        };
        insert."." = {
          action = ".<c-g>u";
        };
        insert.";" = {
          action = ";<c-g>u";
        };
        # }}}
        # save file {{{
        normalVisualOp."<C-s>" = {
          action = "<cmd>w<cr><esc>";
          desc = "Save file";
        };
        # }}}
        # better indenting {{{
        visual."<" = {
          action = "<gv";
        };
        visual.">" = {
          action = ">gv";
        };
        # }}}
        # new file {{{
        normal."<leader>fn" = {
          action = "<cmd>enew<cr>";
          desc = "New File";
        };
        # }}}
        # toggle options {{{
        # TODO: migrate keymaps
        # }}}
        # quit {{{
        normal."<leader>qq" = {
          action = "<cmd>qa<cr>";
          desc = "Quit all";
        };
        # }}}
        # Hightlight under cursor {{{
        normal."<leader>ui" = {
          action = ''vim.show_pos'';
          desc = "Inspect Pos";
        };
        # }}}
        # terminal {{{
        # TODO: floating terminal?
        terminal."<esc><esc>" = {
          action = "<c-\\><c-n>";
          desc = "Enter Normal Mode";
        };
        # }}}
        # window {{{
        normal."<leader>ww" = {
          action = "<C-W>p";
          desc = "Other Window";
        };
        normal."<leader>wd" = {
          action = "<C-W>c";
          desc = "Delete Window";
        };
        normal."<leader>w-" = {
          action = "<C-W>s";
          desc = "Split Window Below";
        };
        normal."<leader>w|" = {
          action = "<C-W>v";
          desc = "Split Window Right";
        };
        normal."<leader>-" = {
          action = "<C-W>s";
          desc = "Split Window Below";
        };
        normal."<leader>|" = {
          action = "<C-W>v";
          desc = "Split Window Right";
        };
        # }}}
        # tabs {{{
        normal."<leader><tab>l" = {
          action = "<cmd>tablast<cr>";
          desc = "Last Tab";
        };
        normal."<leader><tab>f" = {
          action = "<cmd>tabfirst<cr>";
          desc = "First Tab";
        };
        normal."<leader><tab><tab>" = {
          action = "<cmd>tabnew<cr>";
          desc = "New Tab";
        };
        normal."<leader><tab>]" = {
          action = "<cmd>tabnext<cr>";
          desc = "Next Tab";
        };
        normal."<leader><tab>d" = {
          action = "<cmd>tabclose<cr>";
          desc = "Close Tab";
        };
        normal."<leader><tab>[" = {
          action = "<cmd>tabprevious<cr>";
          desc = "Previous Tab";
        };
        # }}}
        # {{{
        normal."<leader>xl" = {
          action = "<cmd>lopen<cr>";
          desc = "Location List";
        };
        normal."<leader>xq" = {
          action = "<cmd>copen<cr>";
          desc = "Quickfix List";
        };
        # }}}
        # bufferline {{{
        normal."<leader>bp" = {
          action = "<cmd>BufferLineTogglePin<cr>";
          desc = "Toggle pin";
          silent = true;
        };
        normal."<leader>bP" = {
          action = "<cmd>BufferLineGroupClose ungrouped<cr>";
          desc = "Delete non-pinned buffers";
          silent = true;
        };
        # }}}
        # noicer ui {{{
        command."<S-Enter>" = {
          action = ''function() require("noice").redirect(vim.fn.getcmdline()) end'';
          lua = true;
          desc = "Redirect Cmdline";
        };
        normal."<leader>snl" = {
          action = ''function() require("noice").cmd("last") end'';
          lua = true;
          desc = "Noice Last Message";
        };
        normal."<leader>snh" = {
          action = ''function() require("noice").cmd("history") end'';
          lua = true;
          desc = "Noice History";
        };
        normal."<leader>sna" = {
          action = ''function() require("noice").cmd("all") end'';
          lua = true;
          desc = "Noice All";
        };
        normal."<leader>snd" = {
          action = ''function() require("noice").cmd("dismiss") end'';
          lua = true;
          desc = "Dismiss All";
        };
        normalVisualOp."<c-f>" = {
          action = ''
            function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end
          '';
          lua = true;
          silent = true;
          expr = true;
          desc = "Scroll forward";
        };
        normalVisualOp."<c-b>" = {
          action = ''function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end
          '';
          lua = true;
          silent = true;
          expr = true;
          desc = "Scroll backward";
        };
        # }}}
        # file explorer {{{
        normal."<leader>fe" = {
          action = ''
            function()
              require("neo-tree.command").execute({ toggle = true, dir = find_git_root_opts()["cwd"] })
            end
          '';
          lua = true;
          desc = "Explorer NeoTree (root dir)";
        };
        normal."<leader>fE" = {
          action = ''
            function() require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() }) end'';
          lua = true;
          desc = "Explorer NeoTree (cwd)";
        };
        normal."<leader>e" = {
          action = "<leader>fe";
          desc = "Explorer NeoTree (root dir)";
          remap = true;
        };
        normal."<leader>E" = {
          action = "<leader>fE";
          desc = "Explorer NeoTree (cwd)";
          remap = true;
        };
        # }}}
        # Telescope {{{
        normal."<leader>," = {
          action = ''function() require("telescope.builtin").buffers({ show_all_buffers = true }) end'';
          lua = true;
          desc = "Switch Buffer";
        };
        normal."<leader>/" = {
          action = ''function() require("telescope.builtin").live_grep(find_git_root_opts()) end'';
          lua = true;
          desc = "Grep (root dir)";
        };
        normal."<leader>:" = {
          action = "<cmd>Telescope command_history<cr>";
          desc = "Command History";
        };
        normal."<leader><space>" = {
          action = ''function() require("telescope.builtin").find_files(find_git_root_opts()) end'';
          lua = true;
          desc = "Find files (root dir)";
        };
        normal."<leader>fb" = {
          action = ''require("telescope.builtin").buffers'';
          lua = true;
          desc = "Buffers";
        };
        normal."<leader>ff" = {
          action = ''<leader><space>'';
          remap = true;
          desc = "Find files (root dir)";
        };
        normal."<leader>fF" = {
          action = ''function() require("telescope.builtin").find_files({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          desc = "Find Files (cwd)";
        };
        normal."<leader>fr" = {
          action = ''require("telescope.builtin").oldfiles'';
          lua = true;
          desc = "Recent Files";
        };
        normal."<leader>fR" = {
          action = ''function() require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          desc = "Recent Files (cwd)";
        };
        normal."<leader>gc" = {
          action = ''require("telescope.builtin").git_commits'';
          lua = true;
          desc = "Git Commits";
        };
        normal."<leader>gs" = {
          action = ''require("telescope.builtin").git_status'';
          lua = true;
          desc = "Git Status";
        };
        normal."<leader>sa" = {
          action = ''require("telescope.builtin").autocommands'';
          lua = true;
          desc = "Auto Commands";
        };
        normal."<leader>sb" = {
          action = ''require("telescope.builtin").current_buffer_fuzzy_find'';
          lua = true;
          desc = "Buffer";
        };
        normal."<leader>sc" = {
          action = ''require("telescope.builtin").command_history'';
          lua = true;
          desc = "Command History";
        };
        normal."<leader>sC" = {
          action = ''require("telescope.builtin").commands'';
          lua = true;
          desc = "Commands";
        };
        normal."<leader>sd" = {
          action = ''function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end'';
          lua = true;
          desc = "Document Diagnostics";
        };
        normal."<leader>sD" = {
          action = ''require("telescope.builtin").diagnostics'';
          lua = true;
          desc = "Workspace Diagnostics";
        };
        normal."<leader>sg" = {
          action = "<leader>/";
          remap = true;
          desc = "Grep (root dir)";
        };
        normal."<leader>sG" = {
          action = ''function() require("telescope.builtin").live_grep(find_git_root_opts()) end'';
          lua = true;
          desc = "Grep (cwd)";
        };
        normal."<leader>sh" = {
          action = ''require("telescope.builtin").help_tags'';
          lua = true;
          desc = "Help Pages";
        };
        normal."<leader>sH" = {
          action = ''require("telescope.builtin").highlights'';
          lua = true;
          desc = "Search Highlights";
        };
        normal."<leader>sk" = {
          action = ''require("telescope.builtin").keymaps'';
          lua = true;
          desc = "Key Maps";
        };
        normal."<leader>sM" = {
          action = ''require("telescope.builtin").man_pages'';
          lua = true;
          desc = "Man Pages";
        };
        normal."<leader>sm" = {
          action = ''require("telescope.builtin").marks'';
          lua = true;
          desc = "Jump to Mark";
        };
        normal."<leader>so" = {
          action = ''require("telescope.builtin").vim_options'';
          lua = true;
          desc = "Options";
        };
        normal."<leader>sR" = {
          action = ''require("telescope.builtin").resume'';
          lua = true;
          desc = "Resume";
        };
        normal."<leader>sw" = {
          action = ''function() require("telescope.builtin").grep_string(find_git_root_opts()) end'';
          lua = true;
          desc = "Word (root dir)";
        };
        normal."<leader>sW" = {
          action = ''function() require("telescope.builtin").grep_string({ cwd = vim.loop.cwd() }) end'';
          lua = true;
          desc = "Word (cwd)";
        };
        normal."<leader>uC" = {
          action = ''
            function() require("telescope.builtin").colorscheme({ enable_preview = true }) end'';
          lua = true;
          desc = "Colourscheme";
        };
        # }}}
        # Trouble {{{
        normal."<leader>xx" = {
          action = ''function() require("trouble").open("document_diagnostics") end'';
          lua = true;
          desc = "Document Diagnostic (Trouble)";
        };
        normal."<leader>xX" = {
          action = ''function() require("trouble").open("workspace_diagnostics") end'';
          lua = true;
          desc = "Document Diagnostic (Trouble)";
        };
        normal."<leader>xL" = {
          action = ''function() require("trouble").open("loclist") end'';
          lua = true;
          desc = "Location List (Trouble)";
        };
        normal."<leader>xQ" = {
          action = ''function() require("trouble").open("quickfix") end'';
          lua = true;
          desc = "Quickfix List (Trouble)";
        };
        normal."[q" = {
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
          desc = "Previous Trouble/Quickfix item";
        };
        normal."]q" = {
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
          desc = "Next Trouble/Quickfix item";
        };
        # }}}
      };
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
          char = "│";
          filetypeExclude = [ "help" "alpha" "dashboard" "neo-tree" "Trouble" "lazy" ];
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
          routes = {
            filter = {
              event = "msg_show";
              find = "%d+L, %d+B";
            };
            view = "mini";
          };
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
            };
            ruff-lsp.enable = true;
            gopls.enable = true;
          };
          onAttach = ''
            if client.name == "ruff_lsp" then
              -- disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
            require("lazyvim.plugins.lsp.keymaps").on_attach(client, bufnr)
            require("lazyvim.plugins.lsp.format").on_attach(client, bufnr)
            vim.keymap.set({ "n", "v" }, "<leader>cf", require("lazyvim.plugins.lsp.format").format, { buffer = bufnr; desc = "Format" })
          '';
        };
        null-ls = {
          enable = true;
          sources.formatting = {
            black = {
              enable = true;
            };
          };
          rootDir = ''require("null-ls.utils").root_pattern(".null-ls-root", ".git")'';
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
          ripgrep;
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
