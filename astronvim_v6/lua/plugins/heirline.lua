---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    opts.statusline = {
      hl = { fg = "none", bg = "none" },
      status.component.mode {
        mode_text = { padding = { left = 0, right = 0 } },
        surround = {
          separator = { "", " " },
        },
      },
      status.component.file_info {
        filetype = {},
        filename = false,
        surround = { color = "none" },
        hl = { fg = "none", bg = "none" },
      },
      status.component.git_branch {
        surround = false,
        hl = { bg = "none" },
      },
      status.component.git_diff {
        added = { padding = { left = 1, right = 0 } },
        changed = { padding = { left = 0, right = 0 } },
        removed = { padding = { left = 0, right = 0 } },
        surround = false,
        hl = { bg = "none" },
      },
      status.component.fill(),
      status.component.cmd_info { hl = { bg = "none" } },
      status.component.fill(),
      status.component.lsp {
        surround = false,
        lsp_client_names = false,
        hl = { bg = "none" },
      },
      status.component.diagnostics {
        surround = { color = "none" },
        hl = { bg = "none" },
      },
      status.component.nav {
        ruler = false,
        surround = false,
        scrollbar = { padding = { left = 1 } },
        percentage = { padding = { left = 0 } },
        hl = { bg = "none" },
      },
    }
  end,
}
