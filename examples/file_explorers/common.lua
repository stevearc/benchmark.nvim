vim.opt.runtimepath:prepend(vim.fn.fnamemodify(".", ":p:h:h:h"))

local bm = require("benchmark")
bm.sandbox()

local num_files = tonumber(vim.env.DIR_SIZE) or 10000

_G.TEST_DIR = string.format("tmp/test_%d", num_files)
_G.DIR_SIZE = num_files
_G.WARM_UP = tonumber(vim.env.WARM_UP) or 1
_G.ITERATIONS = tonumber(vim.env.ITERATIONS) or 10
_G.OUTLIERS = tonumber(vim.env.OUTLIERS) or math.floor(ITERATIONS / 10)

vim.fn.mkdir(TEST_DIR, "p")
require("benchmark.files").create_files(TEST_DIR, "file %d.txt", num_files)

function _G.log_times(times)
  local avg = bm.avg(times, { trim_outliers = OUTLIERS })
  local std_dev = bm.std_dev(times, { trim_outliers = OUTLIERS })
  local lines = {
    table.concat(vim.tbl_map(bm.format_time, times), " "),
    string.format("Average: %s", bm.format_time(avg)),
    string.format("Std deviation: %s", bm.format_time(std_dev)),
  }

  vim.fn.writefile(lines, "tmp/benchmark.txt")
  require("benchmark.files").write_json_file("tmp/benchmark.json", {
    times = times,
    avg = avg,
    std_dev = std_dev,
  })
end
