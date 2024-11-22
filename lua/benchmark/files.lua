local M = {}

local cleanup_dirs = {}
local cleanup_au_id

---Create a temporary directory
---@param template? string String containing X's as a placeholder for the random characters
function M.mkdtemp(template)
  template = template or "benchmark_XXXXXX"
  local cache_path = vim.fn.stdpath("cache")
  local tmp_path = assert(vim.uv.fs_mkdtemp(cache_path .. "/" .. template))
  table.insert(cleanup_dirs, tmp_path)
  if not cleanup_au_id then
    cleanup_au_id = vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        for _, dir in ipairs(cleanup_dirs) do
          vim.fn.delete(dir, "rf")
        end
      end,
    })
  end
  return tmp_path
end

function M.create_files(dir, template, count)
  local last = (dir .. "/" .. template):format(count)
  -- If the last file in this list already exists, assume the rest do too
  if vim.uv.fs_stat(last) then
    return
  end

  for i = 1, count do
    local filename = (dir .. "/" .. template):format(i)
    local fd = vim.uv.fs_open(filename, "a", 420)
    assert(fd)
    vim.uv.fs_close(fd)
  end
end

---@param filename string
---@param contents string
M.write_file = function(filename, contents)
  vim.fn.mkdir(vim.fn.fnamemodify(filename, ":p:h"), "p")
  local fd = assert(vim.uv.fs_open(filename, "w", 420)) -- 0644
  vim.uv.fs_write(fd, contents)
  vim.uv.fs_close(fd)
end

---@param filename string
---@param obj any
M.write_json_file = function(filename, obj)
  ---@type string
  local serialized = vim.json.encode(obj) ---@diagnostic disable-line: assign-type-mismatch
  M.write_file(filename, serialized)
end

return M
