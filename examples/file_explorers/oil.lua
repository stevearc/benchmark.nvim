vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("stevearc/oil.nvim")

---@module 'oil'
---@type oil.SetupOpts
local setup_opts = {
  -- columns = { "icon", "permissions", "size", "mtime" },
}

function _G.jit_profile()
  require("oil").setup(setup_opts)
  local finish = bm.jit_profile({ filename = "tmp/profile.txt" })
  bm.wait_for_user_event("OilEnter", function()
    finish()
  end)
  require("oil").open(TEST_DIR)
end

function _G.flame_profile()
  local start, stop = bm.flame_profile({
    pattern = "oil*",
    filename = "tmp/profile.json",
  })
  require("oil").setup(setup_opts)
  start()
  bm.wait_for_user_event("OilEnter", function()
    stop(function()
      vim.cmd.qall({ mods = { silent = true } })
    end)
  end)
  require("oil").open(TEST_DIR)
end

function _G.benchmark()
  require("oil").setup(setup_opts)
  bm.run({ title = "oil.nvim", iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    bm.wait_for_user_event("OilEnter", callback)
    require("oil").open(TEST_DIR)
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end
