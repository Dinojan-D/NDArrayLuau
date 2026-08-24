--!strict
--!optimize 2
--[=[
    ===============================================================================
                        AUTO-GENERATED FILE, DO NOT EDIT IT MANUALLY !
    ===============================================================================

    Recommanded to only add dirrective native command (@native or --!native).

    date:2026-08-23 14:07
]=]

--[=[
    ===============================================================================
                                  f64-Bits Kernel
    ===============================================================================

    PRIVATE USE

    Implements low-level operations for all f64-bits double-precision-float data types.

    All operations work directly on raw buffers for maximum performance.
]=]

local types = require(script.Parent.Parent.types)

---------------------------------------------------------------------------------------------------
-- Functions Localization
---------------------------------------------------------------------------------------------------

local buffer_len = buffer.len
local buffer_readf64 = buffer.readf64
local buffer_writef64 = buffer.writef64

---------------------------------------------------------------------------------------------------

local Kernel = {}::types.Kernel

--the byte size of the data type
local item_size = 8

---------------------------------------------------------------------------------------------------
-- Seter & Geter
---------------------------------------------------------------------------------------------------
function Kernel.set(b:buffer, offset:number, value:number)
    buffer_writef64(b,offset,value)
end

function Kernel.get(b:buffer, offset:number):number
    return buffer_readf64(b,offset)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations
---------------------------------------------------------------------------------------------------

function Kernel.fill(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer,scalar)
    end
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations By Math Operators
---------------------------------------------------------------------------------------------------

function Kernel.addS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer, buffer_readf64(b, pointer) + scalar)
    end
end

function Kernel.mulS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer, buffer_readf64(b, pointer) * scalar)
    end
end

function Kernel.idivS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer, buffer_readf64(b, pointer) // scalar)
    end
end

function Kernel.modS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer, buffer_readf64(b, pointer) % scalar)
    end
end

function Kernel.powS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writef64(b, pointer, buffer_readf64(b, pointer) ^ scalar)
    end
end

return Kernel