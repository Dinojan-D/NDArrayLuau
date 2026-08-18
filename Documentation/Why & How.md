# Why and How ?

## Projects Environment Constraints

- This project is destined to roblox game development usage. So it will run on the roblox engine.
  Luau code run on the Luau VM, it mean that we don't have the full-power of the low-level languages (C,C++,...), (we can get native optimisation that allow us to run native code but its really limited in memory).

- In common implementation of project like this we use [SIMD (Single Instruction Multiple Data)](https://fr.wikipedia.org/wiki/Single_instruction_multiple_data), but in roblox we don't have control on low-level CPU instruction.(We only have 3Canal-SIMD with [`vector lib`](https://create.roblox.com/docs/fr-fr/reference/engine/libraries/vector))

- More elements in the ndarray it means more iterations.An iteration on ndarray involve reading writing, iterations means more engine-overheading.

## Architectural Solutions

### The Core Choice: Luau Buffers : [`buffer lib`](https://create.roblox.com/docs/reference/engine/libraries/buffer#writestring)

Our goal is to create and array that store contiguous elements in roblox we have two choose for doing this, the table objet (array part of the table objet) or the buffer.

**Why buffer and not a simple table ?**

- **No GC pressure & Zero metadata overhead:**

  A buffer containing N numbers is allocated as a single, contiguous memory object. In contrast, a Luau table stores N individual values. Internally, each value in a table uses a TValue structure, requiring 64 bits for the value/pointer and a 32-bit tag to identify the object's type (+ memory padding).

- **Better memory quantity control:**

  For our projects we need to be able to control a size of an ellement in our array, in luau number objets are in double pression ([IEEE-754 64bits](https://fr.wikipedia.org/wiki/IEEE_754)) so 64bits per number objects (+ internal TValue per number).With buffer we can choose element bits size.

- **Native benefit:**

  With buffer we can benefit native optimisation from the luau interpreter (--!native), this allow to get a lot more performance.

### Kernel Design Implementation:

Before detailing the kernel implementation, it is essential to understand data-types (dtype). A dtype defines the exact bit size and memory layout of each element in an array. By using Luau buffers, we can natively manipulate signed and unsigned 8, 16, and 32-bit integers (i8, u8, i16, u16, i32, u32), as well as single-precision (f32) and double-precision (f64) floats.
A kernel is a ModuleScript containing array manipulation/transformation functions tailored to a specific dtype. Each data-type relies on its own dedicated kernel where every operation is explicitly hardcoded, intentionally setting aside code abstraction and DRY principles.To reconcile runtime performance with long-term maintainability, kernel code is automatically generated from templates at build time, providing a single source of truth for easier debugging.

**Why this choose ?**

- **DType Specific Optimization:**

  Hardcoding individual kernels allows us to apply unique, specialized optimizations tailored to a specific data type-such as bitwise packing for integers or byte-alignment strategies for floating-point values-without compromising other code paths.

- **Compiler & Native Optimizations:**

  A predictable, monomorphic code enables the Luau compiler and native code generator (--!native) to perform aggressive optimizations. These include automatic function inlining, loop unrolling, and direct fastcall for libs(table,buffer,bit32,vector,...).

- **Specific usage per projects:**

  Luau native compilation comes with binary size limits and compilation trade-offs. Isolating each data type into its own ModuleScript allows developers to selectively apply the `--!native` directive (or `@native` function attribute) only to high-throughput kernels, avoiding native code bloat and compilation limits across non-critical parts of the project.
