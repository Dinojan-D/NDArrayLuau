# Luau NDarray

---

THIS PROJECT DEVELOPMENT HAS STOPPED, AND IT WILL PROBABLY NOT RESTART.

- NDArrayLuau was a self-assessment project. Its goal was to test my ability to design, structure and deliver a project end to end: documenting architecture decisions (see the ADR), generating code from templates, and validating behavior with contract tests.

- The core, kernels and operators are tested* (`v0.1.0`)*. Slicing views are experimental. Some small logic issues probably remain to be reviewed and fixed.

- The codebase is kept clean and readable, so anyone can step in easily. You are free to fork it, fix it, extend it or take it over.

---

Goal : Recreate a fast, memory-efficient **N-Dimensional Array** inside the Roblox Engine (Luau), heavily inspired by Python's `numpy.ndarray` ([numpy ndarray](https://numpy.org/doc/2.4/reference/arrays.ndarray.html#constructing-arrays) ) implementation.

## N-Demensional Array In this Project

- **Fixed-size & Homogeneous:** Once allocated, the size and the data type (`dtype`) of the array cannot change. Every element occupies the exact same amount of bytes.
- **Contiguous 1D Storage:** Strictly forbid nested tables (`array[x][y][Z] (3D)`). All data must be stored linearly inside a single 1D container (`buffer`) to ensure maximum CPU cache efficiency.
- **Separation of Memory and View:** The multidimensional structure is a mathematical illusion. The data is 1D; the shape and the strides define how it is read and manipulated using [Row-Major Order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
- **Mathematical Foundations:** This unified 1D structure serves as the raw grid for multi-dimensional operations. By using Row-Major Order equations, we can apply element-wise arithmetic, linear algebra, and reductions across the array, treating the underlying linear buffer as a true mathematical tensor.

## What works

**Data types:** `i8`, `u8`, `i16`, `u16`, `i32`, `u32`, `f32`, `f64`. Each dtype has its own generated kernel, all covered by the kernel contract tests.

### Creating arrays

```lua
local NDarray = require(ReplicatedStorage.Shared.NDarray)

local a = NDarray.zeros({2, 3}, "f32")
local b = NDarray.ones({4}, "u8")
local c = NDarray.copy(a)  -- independent buffer
```

### Reading and writing (0-indexed coordinates)

```lua
a:fill(2)
a:setElement({1, 2}, 42)
print(a:getElement({1, 2}))
```

Values are checked against the dtype range, and coordinates against the shape.

### In-place operators (scalar)

`iadd`, `isub`, `imul`, `idiv`, `iidiv`, `ipow`, `imod`

```lua
a:iadd(1.5):imul(2)  -- chainable, returns the same array
```

- On integer dtypes, `idiv` performs floor division.
- Division or modulo by zero raises an error.
- Integer overflow wraps around.

### Out-of-place operators (scalar on the right)

`+ - * / // ^ %` return a new array and leave the original untouched.

```lua
local d = a * 2
local e = a % 3
```

### Views

`a:transpose()` returns a view that shares the buffer (shape and strides reversed, no data copied).

### Kernel level

Every kernel operation (`fill`, `addS`, `mulS`, `divS`, `idivS`, `modS`, `powS`) supports an `offset`, a `count` and a `step`, so strided iteration is tested at the kernel level.

### Known limitations

- `NDarray.fromArray` is not implemented yet.
- Array-with-array operations and `scalar op array` (e.g. `2 + a`) raise a "not implemented" error.
- Slicing: the slice and length utilities and the strided kernels exist, but there is no public slicing API on `NDarray` yet.
- Some small logic issues probably remain.

## Developpers Informations

### Contributing

The codebase is kept clean and readable, so anyone can step in easily. You are free to fork it, fix it, extend it or take it over.

### Dev Packages (Wally as package manager) :

- Testing : [Jest-Lua](https://jsdotlua.github.io/jest-lua/)

### VSCODE TASKs

Run them from **Terminal>Run Task…** (or `Ctrl+Shift+P` → _Tasks: Run Task_).

| Task                   | What it does                                                                                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GenerateCode: Kernel` | Generates the dtype kernels from templates (`CodeGenerators/kernels/renderer.py`). Prompts for the dtypes, space-separated (e.g. `f32 i32 u8`). Default build task. |
| `Test: Run All`        | Builds the place with Rojo and runs every test suite in Roblox.                                                                                                     |
| `Test: Run Utils`      | Same, utils tests only.                                                                                                                                             |
| `Test: Run Kernels`    | Same, kernel contract tests only.                                                                                                                                   |
| `Test: Run API`        | Same, API tests only (normal + operators).                                                                                                                          |

### Requirements

- Python (see the requirement.txt) for kernel CG
- [Rojo](https://rojo.space) (`rojo build`)
- [run-in-roblox](https://github.com/Roblox/run-in-roblox) and Roblox Studio installed
