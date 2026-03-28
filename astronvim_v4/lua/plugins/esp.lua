-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  {
    "Aietes/esp32.nvim",
  },
  {
    "AstroNvim/astrolsp",
    optional = false,
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local esp32 = require "esp32"

      -- stop Astro from auto‑configuring clangd
      -- opts.handlers = opts.handlers or {}
      -- opts.handlers.clangd = false

      opts.servers = opts.servers or {}
      vim.list_extend(opts.servers, {
        "clangd",
      })

      -- drop in Espressif’s custom settings
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        clangd = esp32.lsp_config(),
      })

      return opts
    end,
  },
}
