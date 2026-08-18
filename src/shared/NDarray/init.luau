--[=[
    ===============================================================================
                                    NDArray Module
    ===============================================================================

    This is the main module of this projet, the NDarray api implementations.

    It provides:
        • Array allocation and construction.
        • Arithmetic operations.
        • Memory management.
        • Operator overloading.
        • Interaction with computation kernels.
        • Object type

    This module is part of the public NDArray API.
]=]

---------------------------------------------------------------------------------------------------
-- Modules
---------------------------------------------------------------------------------------------------
local types = require(script.types)


---------------------------------------------------------------------------------------------------
-- Functions Localization
---------------------------------------------------------------------------------------------------
local create_buffer = buffer.create
local buffer_len = buffer.len

---{Metatable}-------------------------------------------------------------------------------------
local NDarray = {}
NDarray.__index = NDarray
---------------------------------------------------------------------------------------------------


export type NDArray = typeof(setmetatable({}::types.ndarray,NDarray))
return NDarray
