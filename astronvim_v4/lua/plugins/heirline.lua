-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

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
      -- ITS IN THE SECTION BELOW
      status.component.file_info { -- add file_info to breadcrumbs
        file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
        file_modified = false,
        file_read_only = false,
        filetype = false,
        filename = {},
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
}
