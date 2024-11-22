vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("nvim-tree/nvim-tree.lua")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local setup_opts = {
  git = {
    -- This keeps getting disabled due to timeouts and then we get the dreaded
    -- "press ENTER or type command to continue" message.
    enable = false,
  },
}

function _G.jit_profile()
  require("nvim-tree").setup(setup_opts)
  local finish = bm.jit_profile({ filename = "tmp/profile.txt" })
  vim.cmd.NvimTreeOpen({ args = { TEST_DIR } })
  finish()
end

function _G.flame_profile()
  local start, stop = bm.flame_profile({
    pattern = "nvim-tree*",
    filename = "tmp/profile.json",
  })
  require("nvim-tree").setup(setup_opts)
  start()
  vim.cmd.NvimTreeOpen({ args = { TEST_DIR } })
  stop(function()
    vim.cmd.qall({ mods = { silent = true } })
  end)
end

function _G.benchmark()
  require("nvim-tree").setup(setup_opts)
  bm.run({ title = "nvim-tree.lua", iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    require("nvim-tree").purge_all_state()
    vim.cmd.NvimTreeOpen({ args = { TEST_DIR } })
    callback()
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end
