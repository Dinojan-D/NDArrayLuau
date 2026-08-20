--!strict
--!optimize 2
--[=[
    ===============================================================================
                        AUTO-GENERATED FILE, DO NOT EDIT IT MANUALLY !
    ===============================================================================

    Recommanded to only add dirrective native command (@native or --!native).

    date:2026-08-20 12:06
]=]

--[=[
    ===============================================================================
                                  u8-Bits Kernel
    ===============================================================================

    PRIVATE USE

    Implements low-level operations for all u8-bits unsigned-integer data types.

    All operations work directly on raw buffers for maximum performance.
]=]

local types = require(script.Parent.Parent.types)

---------------------------------------------------------------------------------------------------
-- Functions Localization
---------------------------------------------------------------------------------------------------

local buffer_len = buffer.len
local buffer_readu8 = buffer.readu8
local buffer_writeu8 = buffer.writeu8

---------------------------------------------------------------------------------------------------

local Kernel = {}::types.Kernel

--the byte size of the data type
local item_size = 1

---------------------------------------------------------------------------------------------------
-- Seter & Geter
---------------------------------------------------------------------------------------------------
function Kernel.set(b:buffer, offset:number, value:number)
    buffer_writeu8(b,offset,value)
end

function Kernel.get(b:buffer, offset:number):number
    return buffer_readu8(b,offset)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations
---------------------------------------------------------------------------------------------------

local buffer_fill = buffer.fill
function Kernel.fill(b: buffer, offset: number, value: number, count: number?)
    buffer_fill(b,offset,value,count)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations By Math Operators
---------------------------------------------------------------------------------------------------

function Kernel.addS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writeu8(b, pointer, buffer_readu8(b, pointer) + scalar)
    end
end

function Kernel.mulS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writeu8(b, pointer, buffer_readu8(b, pointer) * scalar)
    end
end

function Kernel.idivS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writeu8(b, pointer, buffer_readu8(b, pointer) // scalar)
    end
end

function Kernel.modS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writeu8(b, pointer, buffer_readu8(b, pointer) % scalar)
    end
end

function Kernel.powS(b: buffer, offset: number, scalar: number, count: number?)
    local _size = if count then offset+count*item_size else buffer_len(b)
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writeu8(b, pointer, buffer_readu8(b, pointer) ^ scalar)
    end
end

return Kernel