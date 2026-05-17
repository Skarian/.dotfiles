-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "catppuccin-mocha",
    status = {
      colors = function(colors)
        colors.none = "NONE"
        colors.bg = "NONE"
        colors.section_bg = "NONE"

        for _, section in ipairs {
          "file_info",
          "git_branch",
          "git_diff",
          "diagnostics",
          "cmd_info",
          "nav",
        } do
          colors[section .. "_bg"] = "NONE"
        end

        return colors
      end,
    },
  },
}
