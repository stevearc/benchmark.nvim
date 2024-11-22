# benchmark.nvim

Benchmarking and profiling tools for Neovim plugins

> [!WARNING]  
> This API is not stable and can change at any time. It is recommended to pin to a commit until the 1.0 release.

Check out the [examples/](examples/) to see how to use benchmark.nvim.

If you want to see how benchmark.nvim can be incorporated into your own repo to run benchmarks or do profiling, check out how [oil.nvim does it](https://github.com/stevearc/oil.nvim/blob/master/Makefile).

## API

<!-- API -->

## sandbox()

`sandbox()` \
Sandbox the neovim environment to a temporary directory


## reset()

`reset()` \
Reset neovim buffers and windows


## install_plugin(path)

`install_plugin(path)` \
Clone a plugin and add it to the runtimepath

| Param | Type     | Desc                                                         |
| ----- | -------- | ------------------------------------------------------------ |
| path  | `string` | Path of github plugin (e.g. "stevearc/oil.nvim") or full url |

## avg(nums, opts)

`avg(nums, opts): integer` \
Calculate the average of a list of numbers

| Param | Type                             | Desc |
| ----- | -------------------------------- | ---- |
| nums  | `number[]`                       |      |
| opts  | `nil\|{trim_outliers?: integer}` |      |

## std_dev(nums, opts)

`std_dev(nums, opts): number` \
Calculate the standard deviation of a list of numbers

| Param | Type                             | Desc |
| ----- | -------------------------------- | ---- |
| nums  | `number[]`                       |      |
| opts  | `nil\|{trim_outliers?: integer}` |      |

## run(opts, func, done)

`run(opts, func, done)` \
Run a function multiple times and collect the timing information

| Param       | Type                       | Desc                                                         |
| ----------- | -------------------------- | ------------------------------------------------------------ |
| opts        | `benchmark.RunOpts`        |                                                              |
| >title      | `nil\|string`              | Title to display in the UI                                   |
| >iterations | `nil\|integer`             | Number of times to run the function                          |
| >warm_up    | `nil\|integer`             | Number of warm-up iterations                                 |
| >before     | `nil\|fun()`               | A function to be run before each iteration                   |
| >after      | `nil\|fun()`               | A function to be run after each iteration                    |
| func        | `fun(callback: fun())`     | The function to benchmark. Must call the callback when done. |
| done        | `fun(times_ns: integer[])` | The function to call when all iterations are done            |

## format_time(ns)

`format_time(ns): string` \
Convert a raw nanosecond value to a human readable string

| Param | Type      | Desc |
| ----- | --------- | ---- |
| ns    | `integer` |      |

## jit_profile(opts)

`jit_profile(opts): fun()` \
A thin wrapper around the LuaJIT profiler

| Param     | Type                            | Desc                                                         |
| --------- | ------------------------------- | ------------------------------------------------------------ |
| opts      | `nil\|benchmark.JitProfileOpts` |                                                              |
| >flags    | `nil\|string`                   | See https://luajit.org/ext_profiler.html (default "3Fpli1s") |
| >filename | `nil\|string`                   | Filename to write the profile to                             |

Returns:

| Type  | Desc                                         |
| ----- | -------------------------------------------- |
| fun() | stop Call this function to stop the profiler |

## flame_profile(opts)

`flame_profile(opts): fun(), fun(callback?: fun())` \
Create a profile in the chrome trace format. Call this BEFORE requiring any modules.

| Param     | Type                              | Desc                                                   |
| --------- | --------------------------------- | ------------------------------------------------------ |
| opts      | `nil\|benchmark.FlameProfileOpts` |                                                        |
| >pattern  | `nil\|string`                     | Glob pattern to match modules to profile (e.g. "oil*") |
| >filename | `nil\|string`                     | Filename to write the profile to                       |

Returns:

| Type                  | Desc                                           |
| --------------------- | ---------------------------------------------- |
| fun()                 | start Call this function to start the profiler |
| fun(callback?: fun()) | stop Call this function to stop the profiler   |


<!-- /API -->
