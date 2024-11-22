local M = {}

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
local ROOT = vim.fn.fnamemodify(script_path(), ":p:h:h:h")

---Sandbox the neovim environment to a temporary directory
M.sandbox = function()
  local tmp_path = require("benchmark.files").mkdtemp()
  for _, name in ipairs({ "config", "data", "state", "runtime", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = tmp_path .. name
  end
end

---Reset neovim buffers and windows
M.reset = function()
  vim.cmd.tabnew()
  vim.cmd.tabonly({ mods = { silent = true } })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and bufnr ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end

---Clone a plugin and add it to the runtimepath
---@param path string Path of github plugin (e.g. "stevearc/oil.nvim") or full url
M.install_plugin = function(path)
  local basename = vim.fs.basename(path)
  local plugin_dir = ROOT .. "/plugins"
  vim.fn.mkdir(plugin_dir, "p")
  local plugin_path = plugin_dir .. "/" .. basename
  if not vim.uv.fs_stat(plugin_path) then
    local url = vim.startswith(path, "http") and path or "https://github.com/" .. path
    vim.system({ "git", "clone", url, plugin_path }):wait()
  end
  vim.opt.runtimepath:prepend(plugin_path)
end

M.wait_for_user_event = function(event, callback)
  vim.api.nvim_create_autocmd("User", {
    pattern = event,
    once = true,
    callback = vim.schedule_wrap(callback),
  })
end

---@param nums number[]
---@param outliers integer
---@return number[]
local function trim_outliers(nums, outliers)
  if 2 * outliers >= #nums then
    error("too many outliers to trim.")
  end

  if outliers == 0 then
    return nums
  end
  nums = vim.deepcopy(nums)
  table.sort(nums)
  for _ = 1, outliers do
    table.remove(nums, 1)
    table.remove(nums)
  end
  return nums
end

---Calculate the average of a list of numbers
---@param nums number[]
---@param opts? {trim_outliers?: integer}
---@return integer
M.avg = function(nums, opts)
  ---@type {trim_outliers: integer}
  opts = vim.tbl_deep_extend("keep", opts or {}, { trim_outliers = 0 })

  nums = trim_outliers(nums, opts.trim_outliers)

  local sum = 0
  for _, time in ipairs(nums) do
    sum = sum + time
  end
  return sum / #nums
end

---Calculate the standard deviation of a list of numbers
---@param nums number[]
---@param opts? {trim_outliers?: integer}
---@return number
M.std_dev = function(nums, opts)
  ---@type {trim_outliers: integer}
  opts = vim.tbl_deep_extend("keep", opts or {}, { trim_outliers = 0 })

  nums = trim_outliers(nums, opts.trim_outliers)

  local avg = M.avg(nums)
  local sum = 0
  for _, time in ipairs(nums) do
    local diff = time - avg
    sum = sum + diff * diff
  end
  return math.sqrt(sum / #nums)
end

---@class benchmark.RunOpts
---@field title? string Title to display in the UI
---@field iterations? integer Number of times to run the function
---@field warm_up? integer Number of warm-up iterations
---@field before? fun() A function to be run before each iteration
---@field after? fun() A function to be run after each iteration

---Run a function multiple times and collect the timing information
---@param opts benchmark.RunOpts
---@param func fun(callback: fun()) The function to benchmark. Must call the callback when done.
---@param done fun(times_ns: integer[]) The function to call when all iterations are done
M.run = function(opts, func, done)
  ---@type {title?: string, iterations: integer, warm_up: integer, before?: fun(), after?: fun()}
  opts = vim.tbl_extend("keep", opts, { iterations = 10, warm_up = 0 })
  local ui = require("benchmark.ui")
  -- Map <C-c> to quit with an error so benchmarking can be stopped
  vim.keymap.set("", "<C-c>", "<cmd>cq!<CR>")

  local times = {}
  local run_profile
  local running_avg = 0
  local i = 0
  run_profile = function()
    M.reset()
    local msg
    if i < opts.warm_up then
      if opts.warm_up == 1 then
        msg = { "Warming up..." }
      else
        msg = { string.format("Warming up %d/%d", i + 1, opts.warm_up) }
      end
    else
      msg = { string.format("benchmark %d/%d", #times + 1, opts.iterations) }
    end
    if running_avg > 0 then
      table.insert(msg, string.format("Avg: %s", M.format_time(running_avg)))
      local rem = opts.iterations + opts.warm_up - i
      table.insert(msg, string.format("ETA: %s", M.format_time(running_avg * rem)))
    end
    ui.show_message(msg, { title = opts.title })

    -- Wait a bit to give the message UI time to render
    vim.defer_fn(function()
      if opts.before then
        opts.before()
      end
      local start = vim.uv.hrtime()
      func(function()
        i = i + 1
        local delta = vim.uv.hrtime() - start
        running_avg = running_avg + (delta - running_avg) / i

        if opts.after then
          opts.after()
        end

        if i > opts.warm_up then
          table.insert(times, delta)
        end

        if i < opts.iterations + opts.warm_up then
          vim.schedule(run_profile)
        else
          M.reset()
          done(times)
        end
      end)
    end, 4)
  end

  run_profile()
end

---@param num number
---@return integer
local function round(num)
  return math.floor(num + 0.5)
end

---Convert a raw nanosecond value to a human readable string
---@param ns integer
---@return string
M.format_time = function(ns)
  if ns < 1e3 then -- <1000ns
    return string.format("%dns", ns)
  elseif ns < 1e4 then -- <10μs
    return string.format("%.1fμs", ns / 1e3)
  elseif ns < 1e6 then -- <1000μs
    return string.format("%dμs", round(ns / 1e3))
  elseif ns < 1e7 then -- <10ms
    return string.format("%.1fms", ns / 1e6)
  elseif ns < 1e9 then -- <1000ms
    return string.format("%dms", round(ns / 1e6))
  elseif ns < 1e10 then -- <10s
    return string.format("%.1fs", ns / 1e9)
  elseif ns < 1e12 then -- <1000s
    return string.format("%ds", round(ns / 1e9))
  else
    local sec = ns / 1e9
    local min = math.floor(sec / 60)
    sec = sec % 60
    return string.format("%dm%ds", min, sec)
  end
end

---@class benchmark.JitProfileOpts
---@field flags? string See https://luajit.org/ext_profiler.html (default "3Fpli1s")
---@field filename? string Filename to write the profile to

---A thin wrapper around the LuaJIT profiler
---@param opts? benchmark.JitProfileOpts
---@return fun() stop Call this function to stop the profiler
M.jit_profile = function(opts)
  ---@type {flags: string, filename: string}
  opts = vim.tbl_extend("keep", opts or {}, { flags = "3Fpli1s", filename = "profile.txt" })
  require("jit.p").start(opts.flags, opts.filename)
  return function()
    require("jit.p").stop()
    M.reset()
    vim.cmd.edit({ args = { opts.filename } })
  end
end

---@class benchmark.FlameProfileOpts
---@field pattern? string Glob pattern to match modules to profile (e.g. "oil*")
---@field filename? string Filename to write the profile to

---Create a profile in the chrome trace format. Call this BEFORE requiring any modules.
---@param opts? benchmark.FlameProfileOpts
---@return fun() start Call this function to start the profiler
---@return fun(callback?: fun()) stop Call this function to stop the profiler
M.flame_profile = function(opts)
  ---@type {pattern: string, filename: string}
  opts = vim.tbl_extend("keep", opts or {}, { pattern = "*", filename = "profile.json" })
  local ui = require("benchmark.ui")

  M.install_plugin("stevearc/profile.nvim")
  local profile = require("profile")
  profile.instrument_autocmds()
  profile.instrument(opts.pattern)

  -- Return function that starts the profiling
  return function()
    profile.start()
  end, function(cb)
    if cb then
      ui.show_message({ "Saving profile..." })
      vim.defer_fn(function()
        profile.stop(opts.filename)
        cb()
      end, 10)
    else
      profile.stop(opts.filename)
    end
  end
end

return M
