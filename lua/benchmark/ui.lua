local M = {}

---@param width integer
---@param text string
---@return string
local function center(width, text)
  return string.rep(" ", math.floor((width - vim.api.nvim_strwidth(text)) / 2)) .. text
end

---@class benchmark.ShowMessageOpts
---@field title? string Title to show at the top of the window
---@field width? integer
---@field height? integer
---@field border? string

---@param lines string[]
---@param opts? benchmark.ShowMessageOpts
---@return integer winid
function M.show_message(lines, opts)
  ---@type benchmark.ShowMessageOpts
  opts = opts or {}
  local height = opts.height or math.max(10, #lines + 6)
  local width = opts.width
  if not width then
    width = 30
    for _, line in ipairs(lines) do
      width = math.max(width, vim.api.nvim_strwidth(line) + 4)
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local buf_lines = {}
  for _ = 1, height, 1 do
    table.insert(buf_lines, "")
  end

  local offset = math.floor((height - #lines) / 2 + 0.5)
  for i, v in ipairs(lines) do
    buf_lines[i + offset] = center(width, v)
  end
  if opts.title then
    buf_lines[1] = center(width, opts.title)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buf_lines)
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  local winid = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    width = width,
    height = height,
    style = "minimal",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = opts.border or "rounded",
  })
  return winid
end

return M
