vim.cmd.luafile({ args = { "common.lua" } })
local bm = require("benchmark")
bm.install_plugin("justinmk/vim-dirvish")

function _G.jit_profile()
  error("vim-dirvish is entirely vimscript")
end

function _G.benchmark()
  bm.run({ title = "vim-dirvish", iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    vim.cmd.edit({ args = { TEST_DIR } })
    callback()
  end, function(times)
    log_times(times)
    vim.cmd.qall({ mods = { silent = true } })
  end)
end

function _G.flame_profile()
  error("Netrw is entirely vimscript")
end
