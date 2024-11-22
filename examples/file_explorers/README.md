# File Explorers

This directory contains benchmarking and profiling harnesses for popular file explorers.

## Results

<!-- SIGNATURE -->

Last run on `2024-11-21` with `./generate_graph.py` \
Platform: `macOS-15.1.1-arm64-arm-64bit` \
Neovim:
```
NVIM v0.10.2
Build type: Release
LuaJIT 2.1.1727870382
```

<!-- /SIGNATURE -->

<!-- GRAPH -->

```mermaid
xychart-beta
    x-axis "Num files" [10, 100, 1000, 10000, 100000]
    y-axis "Render time log(ms)" 0 --> 4.5
    line [1.0, 1.0413926851582251, 1.2304489213782739, 1.8808135922807914, 2.9698816437465]
    line [0.47712125471966244, 0.6020599913279624, 1.2041199826559248, 2.12057393120585, 3.1027766148834415]
    line [0.3010299956639812, 0.7781512503836436, 1.662757831681574, 2.6857417386022635, 3.7335182514344876]
    line [0.6020599913279624, 1.1139433523068367, 2.0, 2.9921114877869495, 4.00702192557868]
    line [0.6020599913279624, 1.0791812460476249, 1.9777236052888478, 3.019116290447073, 4.053270566681379]
    line [1.0, 1.3222192947339193, 2.123851640967086, 3.093421685162235, 4.08292891501513]
    line [1.5563025007672873, 1.6020599913279623, 2.187520720836463, 3.1789769472931693, 4.243236537941076]
```

![oil.nvim](https://placehold.co/10x10/3498db/FFF?text=\n) oil.nvim ![vim-dirvish](https://placehold.co/10x10/2ecc71/FFF?text=\n) vim-dirvish ![lir.nvim](https://placehold.co/10x10/e74c3c/FFF?text=\n) lir.nvim ![mini.files](https://placehold.co/10x10/f1c40f/FFF?text=\n) mini.files ![nvim-tree.lua](https://placehold.co/10x10/bdc3c7/FFF?text=\n) nvim-tree.lua ![netrw](https://placehold.co/10x10/ffffff/FFF?text=\n) netrw ![neo-tree.nvim](https://placehold.co/10x10/34495e/FFF?text=\n) neo-tree.nvim

<!-- /GRAPH -->

<!-- TABLE -->

| Plugin        | 10 files | 100 files | 1,000 files | 10,000 files | 100,000 files |
| ------------- | -------- | --------- | ----------- | ------------ | ------------- |
| oil.nvim      | 10ms     | 11ms      | 17ms        | 76ms         | 933ms         |
| vim-dirvish   | 3ms      | 4ms       | 16ms        | 132ms        | 1,267ms       |
| lir.nvim      | 2ms      | 6ms       | 46ms        | 485ms        | 5,414ms       |
| mini.files    | 4ms      | 13ms      | 100ms       | 982ms        | 10,163ms      |
| nvim-tree.lua | 4ms      | 12ms      | 95ms        | 1,045ms      | 11,305ms      |
| netrw         | 10ms     | 21ms      | 133ms       | 1,240ms      | 12,104ms      |
| neo-tree.nvim | 36ms     | 40ms      | 154ms       | 1,510ms      | 17,508ms      |

<!-- /TABLE -->

<!-- REFS -->

Versions tested:

- oil.nvim: `bf81e2a` (2024-11-21)
- vim-dirvish: `2ddd8ee` (2024-09-03)
- lir.nvim: `5b1a927` (2024-05-26)
- mini.files: `6714e73` (2024-11-18)
- nvim-tree.lua: `f7c65e1` (2024-11-18)
- neo-tree.nvim: `a77af2e` (2024-09-16)

<!-- /REFS -->

## Commands

Benchmark a plugin

```bash
./run.sh benchmark oil
```

Get a LuaJIT profile of a plugin

```bash
./run.sh jit_profile oil
```

Get a Chrome trace profile of a plugin

```bash
./run.sh flame_profile oil
```
