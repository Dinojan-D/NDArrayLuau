--!strict
--!optimize 2
--[=[
    ===============================================================================
                        AUTO-GENERATED FILE, DO NOT EDIT IT MANUALLY !
    ===============================================================================

    Recommanded to only add dirrective native command (@native or --!native).

    date:2026-10-03 12:47
]=]

--[=[
    ===============================================================================
                                  i32-Bits Kernel
    ===============================================================================

    PRIVATE USE

    Implements low-level operations for all i32-bits signed-integer data types.

    All operations work directly on raw buffers for maximum performance.
]=]

local types = require(script.Parent.Parent.types)

---------------------------------------------------------------------------------------------------

local Kernel = {}::types.Kernel

--the byte size of the data type
local item_size = 4

---------------------------------------------------------------------------------------------------
-- Seter & Geter
---------------------------------------------------------------------------------------------------
function Kernel.set(b:buffer, offset:number, value:number)
    buffer.writei32(b,offset,value)
end

function Kernel.get(b:buffer, offset:number):number
    return buffer.readi32(b,offset)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations
---------------------------------------------------------------------------------------------------

function Kernel.fill(b: buffer, offset: number, scalar: number, count: number, step:number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writei32(b, pointer, scalar)
    end
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations By Math Operators
---------------------------------------------------------------------------------------------------

function Kernel.addS(b: buffer, offset: number, scalar: number, count: number, step: number?)

    local _size = offset + count * item_size
    _size -= item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size, stepFactor do
        buffer.writei32(b, pointer, buffer.readi32(b, pointer) + scalar)
    end
end

function Kernel.mulS(b: buffer, offset: number, scalar: number, count: number, step: number?)

    local _size = offset + count * item_size
    _size -= item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size, stepFactor do
        buffer.writei32(b, pointer, buffer.readi32(b, pointer) * scalar)
    end
end

function Kernel.divS(b: buffer, offset: number, scalar: number, count: number, step: number?)
error("[NDARAY LIB ERROR]: divion is not available for integers types!")
end

function Kernel.idivS(b: buffer, offset: number, scalar: number, count: number, step: number?)

    local _size = offset + count * item_size
    _size -= item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size, stepFactor do
        buffer.writei32(b, pointer, buffer.readi32(b, pointer) // scalar)
    end
end

function Kernel.modS(b: buffer, offset: number, scalar: number, count: number, step: number?)

    local _size = offset + count * item_size
    _size -= item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size, stepFactor do
        buffer.writei32(b, pointer, buffer.readi32(b, pointer) % scalar)
    end
end

function Kernel.powS(b: buffer, offset: number, scalar: number, count: number, step: number?)

    local _size = offset + count * item_size
    _size -= item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size, stepFactor do
        buffer.writei32(b, pointer, buffer.readi32(b, pointer) ^ scalar)
    end
end

return Kernel