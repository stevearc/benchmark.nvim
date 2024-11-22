vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("nvim-lua/plenary.nvim")
bm.install_plugin("tamago324/lir.nvim")

local setup_opts = {}

function _G.jit_profile()
  require("lir").setup(setup_opts)
  local finish = bm.jit_profile({ filename = "tmp/profile.txt" })
  vim.cmd.edit({ args = { TEST_DIR } })
  finish()
end

function _G.flame_profile()
  local start, stop = bm.flame_profile({
    pattern = "lir*",
    filename = "tmp/profile.json",
  })
  require("lir").setup(setup_opts)
  start()
  vim.cmd.edit({ args = { TEST_DIR } })
  stop(function()
    vim.cmd.qall({ mods = { silent = true } })
  end)
end

function _G.benchmark()
  require("lir").setup(setup_opts)
  bm.run({ title = "lir.nvim", iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    vim.cmd.edit({ args = { TEST_DIR } })
    callback()
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end
