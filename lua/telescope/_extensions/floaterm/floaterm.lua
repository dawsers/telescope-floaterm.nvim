local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local floaterm = {}

local function floaterm_select()
  return function(prompt_buffer)
    local selection = action_state.get_selected_entry()
    if not selection then
      return
    end
    actions.close(prompt_buffer)
    vim.fn['floaterm#terminal#open_existing'](selection.bufnr)
    vim.api.nvim_eval("timer_start(100, {->execute('doautocmd BufEnter')})")
  end
end


local search_displayer = entry_display.create {
  separator = " ",
  items = {
    { width = 11 },
    { remaining = true },
  },
}

local make_floaterm_display = function(entry)
  return search_displayer {
    { entry.bufnr or "", "TelescopeFloatermBufNumber" },
    { (entry.name or ""), "TelescopeFloatermBufName" },
  }
end

floaterm.search = function(opts)
  opts = opts or {}
  local bufnrs = vim.fn['floaterm#buflist#gather']()

  table.sort(bufnrs, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)

  for i, v in ipairs(bufnrs) do
    local bufnr = v
    local name = vim.fn.getbufvar(bufnr, 'term_title')
    bufnrs[i] = { bufnr = bufnr, name = name }
  end
  pickers.new(opts, {
    prompt_title = "Select Terminal",
    finder = finders.new_table {
      results = bufnrs,
      entry_maker = function(entry)
        entry.value = entry.bufnr
        entry.ordinal = entry.name
        entry.display = make_floaterm_display
        return entry
      end
    },
    previewer = conf.grep_previewer(opts),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(floaterm_select(prompt_bufnr))
      return true
    end,
  }):find()
end

return floaterm
