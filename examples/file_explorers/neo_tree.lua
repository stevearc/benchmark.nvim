vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("nvim-lua/plenary.nvim")
bm.install_plugin("MunifTanjim/nui.nvim")
bm.install_plugin("nvim-neo-tree/neo-tree.nvim")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loadplugins = 1

local setup_opts = {
  enable_git_status = false,
  enable_diagnostics = false,
  filesystem = {
    -- This is required to list more than 1000 files
    async_directory_scan = "always",
    filtered_items = {
      -- This is required to show any of the files at all
      hide_gitignored = false,
    },
  },
}
local cwd = vim.fn.getcwd()

-- This is a janky way to detect when it's completed,
-- but there's no way to get a callback when it's done.
-- This isn't even correct, because the rendering is not fully done when the buffer is populated.
local function wait_neotree_open()
  vim.wait(60000, function()
    return vim.api.nvim_buf_line_count(0) >= DIR_SIZE
  end, 1)
end

function _G.jit_profile()
  require("neo-tree").setup(setup_opts)
  local finish = bm.jit_profile({ filename = "tmp/profile.txt" })
  vim.cmd.Neotree({ args = { "dir=" .. TEST_DIR } })
  wait_neotree_open()
  finish()
end

function _G.flame_profile()
  local start, stop = bm.flame_profile({
    pattern = "neo-tree*",
    filename = "tmp/profile.json",
  })
  require("neo-tree").setup(setup_opts)
  start()
  vim.cmd.Neotree({ args = { "dir=" .. TEST_DIR } })
  wait_neotree_open()
  stop(function()
    vim.cmd.qall({ mods = { silent = true } })
  end)
end

function _G.benchmark()
  require("neo-tree").setup(setup_opts)
  bm.run({
    title = "neo-tree.nvim",
    iterations = ITERATIONS,
    warm_up = WARM_UP,
    after = function()
      vim.cmd.Neotree({ args = { "close" } })
      vim.wait(10)
      -- Have to cd back because neo-tree changes the cwd and that messes up where we're writing the
      -- benchmark file
      vim.cmd.cd({ args = { cwd }, mods = { noautocmd = true } })
      vim.wait(20)
    end,
  }, function(callback)
    vim.cmd.Neotree({ args = { "dir=" .. TEST_DIR } })
    wait_neotree_open()
    callback()
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end
