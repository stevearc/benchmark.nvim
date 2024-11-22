vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("echasnovski/mini.nvim")

local setup_opts = {}

function _G.jit_profile()
  require("mini.files").setup(setup_opts)
  local finish = bm.jit_profile({ flags = "5Fpli1s", filename = "tmp/profile.txt" })
  bm.wait_for_user_event("MiniFilesExplorerOpen", function()
    finish()
  end)
  MiniFiles.open(TEST_DIR)
end

function _G.flame_profile()
  local start, stop = bm.flame_profile({
    pattern = "mini*",
    filename = "tmp/profile.json",
  })
  require("mini.files").setup(setup_opts)
  start()
  bm.wait_for_user_event("MiniFilesExplorerOpen", function()
    stop(function()
      vim.cmd.qall({ mods = { silent = true } })
    end)
  end)
  MiniFiles.open(TEST_DIR)
end

function _G.benchmark()
  require("mini.files").setup(setup_opts)
  bm.run({ title = "mini.files", iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    bm.wait_for_user_event("MiniFilesExplorerOpen", callback)
    MiniFiles.open(TEST_DIR)
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end
