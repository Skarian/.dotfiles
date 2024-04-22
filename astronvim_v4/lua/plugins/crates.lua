-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "Saecki/crates.nvim",
  opts = {
    popup = {
      autofocus = true,
    },
    on_attach = function(bufnr)
      local crates = require "crates"
      local utils = require "astrocore"
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
}
