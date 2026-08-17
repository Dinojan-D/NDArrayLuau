# Luau NDarray

Goal : Recreate a fast, memory-efficient **N-Dimensional Array** inside the Roblox Engine (Luau), heavily inspired by Python's `numpy.ndarray` ([numpy ndarray](https://numpy.org/doc/2.4/reference/arrays.ndarray.html#constructing-arrays) ) implementation.

## N-Demensional Array In this Project

- **Fixed-size & Homogeneous:** Once allocated, the size and the data type (`dtype`) of the array cannot change. Every element occupies the exact same amount of bytes.
- **Contiguous 1D Storage:** Strictly forbid nested tables (`array[x][y][Z] (3D)`). All data must be stored linearly inside a single 1D container (`buffer`) to ensure maximum CPU cache efficiency.
- **Separation of Memory and View:** The multidimensional structure is a mathematical illusion. The data is 1D; the shape and the strides define how it is read and manipulated using [Row-Major Order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
- **Mathematical Foundations:** This unified 1D structure serves as the raw grid for multi-dimensional operations. By using Row-Major Order equations, we can apply element-wise arithmetic, linear algebra, and reductions across the array, treating the underlying linear buffer as a true mathematical tensor.

## Developpers Informations

### Dev Packages (Wally as package manager) :

- Testing : [Jest-Lua](https://jsdotlua.github.io/jest-lua/)

### Documentations :

- A complete documentations of this project in the root folder as '/Documentation'.
