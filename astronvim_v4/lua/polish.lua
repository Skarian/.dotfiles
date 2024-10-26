-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.opt.clipboard:append { "unnamedplus" }

-- Sets wordwrap always on
vim.cmd "autocmd BufEnter * set wrap"
-- Sets 0 to go to first character instead of first whitespace
vim.api.nvim_set_keymap("n", "0", "^", { noremap = true })
-- Sets j to gj and k to gk, ensures corrent line jumping with wordwrap on
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, noremap = true })

-- Autocommand to start GDScript LSP server in Godot projects
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local root_patterns = { "project.godot", ".godot" }
    local current_dir = vim.fn.getcwd()

    for _, pattern in ipairs(root_patterns) do
      if vim.fn.findfile(pattern, current_dir .. ";") ~= "" then
        -- We're in a Godot project, start the LSP server
        local pipe = "./godothost"
        vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
        vim.notify("Listening for Godot LSP...", vim.log.levels.INFO)
        break
      end
    end
  end,
  group = vim.api.nvim_create_augroup("GDScriptLSPAutostart", { clear = true }),
})
