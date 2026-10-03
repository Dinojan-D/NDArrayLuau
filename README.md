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
