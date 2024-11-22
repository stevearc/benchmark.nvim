-- Customize the benchmark parameters
-- how many times to run the function
local ITERATIONS = 1000
-- how many times to run the function before we start recording
local WARM_UP = 10
-- discard this many of the fastest and slowest results
local NUM_OUTLIERS = 10

-- Add benchmark.nvim to the runtimepath
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(".", ":p:h:h:h"))

local bm = require("benchmark")
-- Ensure this Neovim instance uses new dirs for config, cache, state, etc
bm.sandbox()

---Global function to run our benchmark
function _G.benchmark()
  bm.run({ iterations = ITERATIONS, warm_up = WARM_UP }, function(callback)
    -- PUT YOUR CODE HERE

    callback()
  end, function(times)
    local avg = bm.avg(times, { trim_outliers = NUM_OUTLIERS })
    local std_dev = bm.std_dev(times, { trim_outliers = NUM_OUTLIERS })
    local lines = {
      string.format("Average: %s", bm.format_time(avg)),
      string.format("Std deviation: %s", bm.format_time(std_dev)),
    }
    require("benchmark.ui").show_message(lines, { title = "Results" })
  end)
end
