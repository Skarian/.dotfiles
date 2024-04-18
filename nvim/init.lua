return {
  diagnostics = {
    virtual_text = false,
    virtual_lines = false,
    update_in_insert = false,
  },
  options = {
    opt = {
      showtabline = 1,
    },
  },
  mappings = {
    n = {
      -- Open Alpha Automatically When No More Buffers
      ["<leader>c"] = {
        function()
          local function exitNeotreeIfCurrentWindow()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            if #wins > 1 and vim.api.nvim_get_option_value("filetype", { win = wins[1] }) == "neo-tree" then
              vim.fn.win_gotoid(wins[2]) -- go to non-neo-tree window to toggle alpha
            end
          end

          local bufs = vim.fn.getbufinfo { buflisted = true }
          local is_available = require("astronvim.utils").is_available "alpha-nvim"

          exitNeotreeIfCurrentWindow()

          if is_available and bufs[2] then
            require("astronvim.utils.buffer").close()
          else
            if is_available and not bufs[2] and bufs[1] then
              require("alpha").start(false, require("alpha").default_config)
              require("astronvim.utils.buffer").close_all()
            end
          end
        end,
        desc = "Close buffer",
      },
      ["<leader>le"] = {
        function() require("lsp_lines").toggle() end,
        desc = "Expand diagnostics",
      },
      -- Mardown preview
      ["<leader>m"] = { name = " Markdown" },
      ["<leader>mp"] = { "<cmd>MarkdownPreview<cr>", desc = "Markdown preview" },
      ["<leader>ms"] = { "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown preview stop" },
      ["<leader>mt"] = { "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview toggle" },
      ["<leader>mi"] = { "<cmd>PasteImg<cr>", desc = "Markdown paste image" },
    },
  },
  lsp = {
    servers = { "rust_analyzer" },
    config = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              loadOutDirsFromCheck = true,
              features = "all",
            },
            checkOnSave = {
              command = "clippy",
            },
            procMacro = {
              enable = true,
            },
            experimental = {
              procAttrMacros = true,
            },
          },
        },
      },
    },
  },
  colorscheme = "catppuccin-mocha",
  plugins = {
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-emoji",
        "jc-doyle/cmp-pandoc-references",
        "kdheepak/cmp-latex-symbols",
        "lukas-reineke/cmp-under-comparator",
      },
      opts = function(_, opts)
        local cmp = require "cmp"
        local lspkind = require "lspkind"
        local compare = require "cmp.config.compare"

        local function truncateString(input, length)
          if string.len(input) > length then
            return string.sub(input, 1, length - 3) .. "..."
          else
            return input
          end
        end

        return require("astronvim.utils").extend_tbl(opts, {
          sources = cmp.config.sources {
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip", priority = 750 },
            { name = "pandoc_references", priority = 725 },
            { name = "latex_symbols", priority = 700 },
            { name = "emoji", priority = 700 },
            { name = "calc", priority = 650 },
            { name = "path", priority = 500 },
            { name = "buffer", priority = 250 },
          },
          -- From https://github.com/nikbrunner/vin/blob/e65519ee346d4c3b44df7157fce9d67ddbb66b06/lua/vin/plugins/lsp/cmp.lua#L1
          formatting = {
            fields = { "abbr", "kind", "menu" },
            format = lspkind.cmp_format {
              -- mode = "symbol_text",
              mode = "symbol",
              maxwidth = 50,
              ellipses_char = "...",
              before = function(entry, vim_item)
                if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
                  vim_item.menu = truncateString(entry.completion_item.detail, 50)
                else
                  vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    ultisnips = "[US]",
                    luasnip = "[Luasnip]",
                    nvim_lua = "[Lua]",
                    path = "[Path]",
                    buffer = "[Buffer]",
                    emoji = "[Emoji]",
                    omni = "[Omni]",
                  })[entry.source.name]
                end
                return vim_item
              end,
            },
          },
          sorting = {
            comparators = {
              compare.exact,
              compare.score,
              require("cmp-under-comparator").under,
              compare.locality,
              compare.recently_used,
              compare.offset,
              compare.order,
            },
          },
          experimental = { ghost_text = true },
        })
      end,
    },
    {
      "goolord/alpha-nvim",
      opts = function(_, opts) -- override the options using lazy.nvim
        opts.section.header.val = { -- change the header section value
          "███████╗██╗  ██╗ █████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "██╔════╝██║ ██╔╝██╔══██╗██╔══██╗██║   ██║██║████╗ ████║",
          "███████╗█████╔╝ ███████║██████╔╝██║   ██║██║██╔████╔██║",
          "╚════██║██╔═██╗ ██╔══██║██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║",
          "███████║██║  ██╗██║  ██║██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts) -- override the options using lazy.nvim
        local actions = require "telescope.actions"
        opts.pickers = {
          -- Sorts buffer picker by most recent, removes current buffer and adds delete keymap
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
            mappings = {
              n = {
                ["d"] = actions.delete_buffer,
              },
            },
          },
        }
      end,
    },
    {
      -- Running a fork that fixes https://github.com/ekickx/clipboard-image.nvim/pull/48#issuecomment-1589760763
      "postfen/clipboard-image.nvim",
      ft = "markdown",
      lazy = true,
      cmd = "PasteImg",
      branch = "patch-1",
      config = function()
        require("clipboard-image").setup {
          default = {
            img_dir = { "%:p:h", "img", "%:t:r" },
            img_dir_txt = { "img", "%:t:r" },
          },
        }
      end,
    },
    -- Originally set to BufRead event but started breaking, changed to VeryLazy
    {
      "jinh0/eyeliner.nvim",
      event = "VeryLazy",
      opts = {
        highlight_on_key = true,
        dim = true,
      },
    },
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.colorscheme.catppuccin" },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      opts = function(_, opts)
        opts.integrations.native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        }
      end,
    },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.rust" },
    {
      "simrat39/rust-tools.nvim",
      opts = {
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
        server = {
          on_attach = function(client, bufnr)
            -- override here. call lsp on attach and then add own custom logic.
            require("astronvim.utils.lsp").on_attach(client, bufnr)
            local rt = require "rust-tools"

            local utils = require "astronvim.utils"

            local function rust_disable_inlay_hints() vim.cmd "RustDisableInlayHints" end

            local function rust_enable_inlay_hints() vim.cmd "RustEnableInlayHints" end

            utils.set_mappings({
              n = {
                ["<leader>r"] = { name = " Rust Tools" },
                ["<leader>rh"] = { rt.hover_actions.hover_actions, desc = "Rust Hover Actions" },
                ["<leader>ra"] = { rt.code_action_group.code_action_group, desc = "Rust Code Actions" },
                ["<leader>rd"] = { rust_disable_inlay_hints, desc = "Rust Disable Inlay Hints" },
                ["<leader>re"] = { rust_enable_inlay_hints, desc = "Rust Enable Inlay Hints" },
              },
            }, { buffer = bufnr })
          end,
        },
      },
    },
    {
      "Saecki/crates.nvim",
      opts = {
        popup = {
          autofocus = true,
        },
        on_attach = function(bufnr)
          local crates = require "crates"
          local utils = require "astronvim.utils"
          utils.set_mappings({
            n = {
              ["<leader>r"] = { name = "+ Crates" },
              ["<leader>rt"] = { crates.toggle, desc = "Toggle crates" },
              ["<leader>rr"] = { crates.reload, desc = "Reload crates" },
              ["<leader>rv"] = { crates.show_versions_popup, desc = "Show crate versions popup" },
              ["<leader>rf"] = { crates.show_features_popup, desc = "Show crate features popup" },
              ["<leader>rd"] = { crates.show_dependencies_popup, desc = "Show crate dependencies popup" },
              ["<leader>ru"] = { crates.update_crate, desc = "Update crate" },
              ["<leader>ra"] = { crates.update_all_crates, desc = "Update all crates" },
              ["<leader>rU"] = { crates.upgrade_crate, desc = "Upgrade crate" },
              ["<leader>rA"] = { crates.upgrade_all_crates, desc = "Upgrade all crates" },
              ["<leader>rH"] = { crates.open_homepage, desc = "Open crate homepage" },
              ["<leader>rR"] = { crates.open_repository, desc = "Open crate repository" },
              ["<leader>rD"] = { crates.open_documentation, desc = "Open crate documentation" },
              ["<leader>rC"] = { crates.open_crates_io, desc = "Open crates.io" },
            },
          }, { buffer = bufnr })
        end,
      },
    },
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.typescript" },
    { import = "astrocommunity.pack.svelte" },
    { import = "astrocommunity.pack.tailwindcss" },
    { import = "astrocommunity.pack.markdown" },
    { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
    { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
    { import = "astrocommunity.diagnostics.trouble-nvim" },
    { import = "astrocommunity.motion.nvim-surround" },
    { import = "astrocommunity.motion.mini-move" },
    { import = "astrocommunity.file-explorer.oil-nvim" },
    { import = "astrocommunity.utility.noice-nvim" },
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      cond = not vim.g.neovide,
      dependencies = { "MunifTanjim/nui.nvim" },
      opts = function(_, opts)
        local utils = require "astronvim.utils"
        return utils.extend_tbl(opts, {
          lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
              ["cmp.entry.get_documentation"] = true,
            },
            progress = { enabled = false },
            signature = { enabled = false },
            message = { enabled = true },
          },
          presets = {
            bottom_search = false, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = utils.is_available "inc-rename.nvim", -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true, -- add a border to hover docs and signature help
          },
          -- Disables annoying notifications
          routes = {
            {
              filter = {
                event = "notify",
                find = "No information available",
              },
              opts = { skip = true },
              desc = "Skip 'No information available' messages from LSP",
            },
            { filter = { event = "msg_show", find = "%d+L,%s%d+B" }, opts = { skip = true } }, -- skip save notifications
            { filter = { event = "msg_show", find = "^%d+ more lines$" }, opts = { skip = true } }, -- skip paste notifications
            { filter = { event = "msg_show", find = "^%d+ fewer lines$" }, opts = { skip = true } }, -- skip delete notifications
            { filter = { event = "msg_show", find = "^%d+ lines yanked$" }, opts = { skip = true } }, -- skip yank notifications
          },
          -- Disables scrollbar causing clipping issues
          views = {
            hover = {
              scrollbar = false,
              size = { max_width = 70 },
            },
          },
        })
      end,
      init = function() vim.g.lsp_handlers_enabled = false end,
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "BufRead",
      config = function()
        require("lsp_signature").setup {
          hint_enable = false,
          toggle_key = "<C-k>",
          toggle_key_flip_floatwin_setting = true,
        }
      end,
    },
    {
      -- https://code.mehalter.com/AstroNvim_user/~files/master/plugins/heirline.lua
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require "astronvim.utils.status"

        local separators = {
          left = { "", "" }, -- separator for the left side of the statusline
          right = { "", "" }, -- separator for the right side of the statusline
          both = { "", " " },
        }
        -- Note for self next time, if you want to do spacing do the surround separator like in status.component.mode; avoid padding
        -- NEEDS FIXING, SPACING INCONSISTENT RN
        --
        opts.statusline = { -- statusline
          hl = { fg = "none", bg = "none" },
          -- hl = { fg = "fg", bg = "bg" },
          status.component.mode {
            mode_text = { padding = { left = 0, right = 0 } },
            surround = {
              separator = separators.both,
            },
          }, -- add the mode text
          status.component.file_info {
            filetype = {},
            filename = false,
            hl = { fg = "none", bg = "none" },
          },
          status.component.git_branch { hl = { bg = "none" }, surround = false },
          status.component.git_diff {
            hl = { bg = "none" },
            added = { padding = { left = 1, right = 1 } },
            changed = { padding = { left = 1, right = 1 } },
            removed = { padding = { left = 1, right = 1 } },
            surround = { separator = "left", color = "git_diff_bg", condition = status.condition.is_git_repo },
          },
          status.component.fill(),
          status.component.cmd_info { hl = { bg = "none" } },
          status.component.fill(),
          status.component.lsp { lsp_client_names = false, hl = { bg = "none" } },
          status.component.diagnostics { hl = { bg = "none" } },
          -- status.component.treesitter(),
          status.component.nav {
            hl = { bg = "none" },
            ruler = false,
            surround = false,
            scrollbar = { padding = { left = 1 } },
            percentage = { padding = { left = 0 } },
          },
        }

        opts.winbar[1][1] = status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } }
        opts.winbar[2] = {
          status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } },
          status.component.file_info { -- add file_info to breadcrumbs
            file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbar", true),
            surround = false,
            update = "BufEnter",
          },
          status.component.breadcrumbs {
            icon = { hl = true },
            hl = status.hl.get_attributes("winbar", true),
            prefix = true,
            padding = { left = 0 },
          },
        }
        return opts
      end,
    },
    {
      -- Temporary fix for closing brackets in JXS ex: <Component /> accidentally becomes <Component /Component>
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        -- add more things to the ensure_installed table protecting against community packs modifying it
        opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
          -- "lua"
        })
        opts.autotag.enable_close_on_slash = false
      end,
    },
    { import = "astrocommunity.scrolling.neoscroll-nvim" },
    {
      -- "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      dir = "~/projects/lsp_lines",
      event = "LspAttach",
      opts = {},
    },
  },
  -- This function is run last
  -- good place to configure mappings and vim options
  polish = function()
    vim.opt.clipboard:append { "unnamedplus" }

    -- Sets wordwrap always on
    vim.cmd "autocmd BufEnter * set wrap"
    -- Sets 0 to go to first character instead of first whitespace
    vim.api.nvim_set_keymap("n", "0", "^", { noremap = true })
    -- Sets j to gj and k to gk, ensures corrent line jumping with wordwrap on
    vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, noremap = true })
    vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, noremap = true })
  end,
}
