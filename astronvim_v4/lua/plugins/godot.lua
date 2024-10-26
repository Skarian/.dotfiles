-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  -- Linting and formatting
  -- May need to manually install in Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "gdscript" })
    end,
  },
  -- LSP Integration powered by running Godot instance
  -- {
  --   "AstroNvim/astrolsp",
  --   ---@param opts AstroLSPOpts
  --   opts = function(plugin, opts)
  --     -- Local Variables
  --     local os
  --     if vim.fn.has "macunix" then
  --       os = "mac"
  --     elseif vim.fn.has "win32" then
  --       os = "win"
  --     else
  --       os = "linux"
  --     end
  --
  --     -- Add gdscript to server list
  --     opts.servers = opts.servers or {}
  --     vim.list_extend(opts.servers, {
  --       "gdscript",
  --     })
  --
  --     -- Server setup
  --     opts.config = require("astrocore").extend_tbl(opts.config or {}, {
  --       gdscript = {
  --         cmd = (function()
  --           if os == "mac" then
  --             return vim.lsp.rpc.connect("127.0.0.1", 6005)
  --           elseif os == "win" then
  --             return { "ncat", "localhost", "6005" }
  --           else
  --             return nil -- or provide a default command if needed
  --           end
  --         end)(),
  --         filetypes = { "gd", "gdscript" },
  --         root_dir = require("lspconfig.util").root_pattern("project.godot", ".godot"),
  --       },
  --     })
  --   end,
  -- },
  -- Syntax Highlighting / TS
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "gdscript", "glsl", "godot_resource" })
      end
    end,
  },
  {
    "Teatek/gdscript-extended-lsp.nvim",
    config = function()
      local on_attach = function()
        local gdplugin = require "gdscript_extended"
        if vim.fn.exists ":GodotDoc" == 0 then
          vim.api.nvim_create_user_command("GodotDoc", function(cmd)
            -- Change the function depending on what you prefer
            gdplugin.open_doc_in_current_win(cmd.args)
          end, {
            nargs = 1,
            complete = function() return gdplugin.get_native_classes() end,
          })
        end

        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
        vim.keymap.set(
          "n",
          "gD",
          "<Cmd>lua require('gdscript_extended').open_doc_on_cursor_in_current_win()<CR>",
          { buffer = 0 }
        )
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = 0 })
        vim.keymap.set("n", "<leader>D", "<Cmd>Telescope gdscript_extended default<CR>", { buffer = 0 })
        vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { buffer = 0 })
        vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { buffer = 0 })
        vim.keymap.set("n", "<leader>dl", "<Cmd>Telescope diagnostics<CR>", { buffer = 0 })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = 0 })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = 0 })
        vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { buffer = 0 })
      end

      local doc_conf = function(bufnr)
        vim.keymap.set(
          "n",
          "gD",
          "<Cmd>lua require('gdscript_extended').open_doc_on_cursor_in_current_win()<CR>",
          { buffer = bufnr }
        )
        vim.keymap.set("n", "<leader>D", "<Cmd>Telescope gdscript_extended default<CR>", { buffer = bufnr })
      end
      require("gdscript_extended").setup {
        on_attach = on_attach,
        doc_keymaps = {
          user_config = doc_conf,
        },
      }
    end,
  },
  -- Fixed indentation
  {
    "habamax/vim-godot",
    event = "BufEnter *.gd",
    config = function()
      local null_ls = require "null-ls"
      null_ls.register {
        -- gdlint didn't work
        -- null_ls.builtins.diagnostics.gdlint,
        null_ls.builtins.formatting.gdformat,
      }

      vim.cmd [[
  setlocal foldmethod=expr
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal indentexpr=
  ]]
    end,
  },
}
