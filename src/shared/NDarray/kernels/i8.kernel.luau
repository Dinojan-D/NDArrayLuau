--!strict
--!optimize 2
--[=[
    ===============================================================================
                        AUTO-GENERATED FILE, DO NOT EDIT IT MANUALLY !
    ===============================================================================

    Recommanded to only add dirrective native command (@native or --!native).

    date:2026-08-24 11:12
]=]

--[=[
    ===============================================================================
                                  i8-Bits Kernel
    ===============================================================================

    PRIVATE USE

    Implements low-level operations for all i8-bits signed-integer data types.

    All operations work directly on raw buffers for maximum performance.
]=]

local types = require(script.Parent.Parent.types)

---------------------------------------------------------------------------------------------------
-- Functions Localization
---------------------------------------------------------------------------------------------------

local buffer_len = buffer.len
local buffer_readi8 = buffer.readi8
local buffer_writei8 = buffer.writei8

---------------------------------------------------------------------------------------------------

local Kernel = {}::types.Kernel

--the byte size of the data type
local item_size = 1

---------------------------------------------------------------------------------------------------
-- Seter & Geter
---------------------------------------------------------------------------------------------------
function Kernel.set(b:buffer, offset:number, value:number)
    buffer_writei8(b,offset,value)
end

function Kernel.get(b:buffer, offset:number):number
    return buffer_readi8(b,offset)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations
---------------------------------------------------------------------------------------------------

local buffer_fill = buffer.fill
function Kernel.fill(b: buffer, offset: number, value: number, count: number)
    buffer_fill(b,offset,value,count)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations By Math Operators
---------------------------------------------------------------------------------------------------

function Kernel.addS(b: buffer, offset: number, scalar: number, count: number)
    local _size = offset+count*item_size
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writei8(b, pointer, buffer_readi8(b, pointer) + scalar)
    end
end

function Kernel.mulS(b: buffer, offset: number, scalar: number, count: number)
    local _size = offset+count*item_size
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writei8(b, pointer, buffer_readi8(b, pointer) * scalar)
    end
end

function Kernel.idivS(b: buffer, offset: number, scalar: number, count: number)
    local _size = offset+count*item_size
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writei8(b, pointer, buffer_readi8(b, pointer) // scalar)
    end
end

function Kernel.modS(b: buffer, offset: number, scalar: number, count: number)
    local _size = offset+count*item_size
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writei8(b, pointer, buffer_readi8(b, pointer) % scalar)
    end
end

function Kernel.powS(b: buffer, offset: number, scalar: number, count: number)
    local _size = offset+count*item_size
    _size -=1

    for pointer = offset, _size,item_size do
        buffer_writei8(b, pointer, buffer_readi8(b, pointer) ^ scalar)
    end
end

return Kernel