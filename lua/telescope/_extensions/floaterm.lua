local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

-- Set default values for highlighting groups
vim.cmd("highlight default link TelescopeFloatermBufNumber Number")
vim.cmd("highlight default link TelescopeFloatermBufName Function")

return telescope.register_extension {
  exports = {
    floaterm = require("telescope._extensions.floaterm.floaterm").search,
  }
}

