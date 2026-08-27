--!strict
--!optimize 2
--[=[
    ===============================================================================
                        AUTO-GENERATED FILE, DO NOT EDIT IT MANUALLY !
    ===============================================================================

    Recommanded to only add dirrective native command (@native or --!native).

    date:2026-08-27 10:44
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

local Kernel = {}::types.Kernel

--the byte size of the data type
local item_size = 1

---------------------------------------------------------------------------------------------------
-- Seter & Geter
---------------------------------------------------------------------------------------------------
function Kernel.set(b:buffer, offset:number, value:number)
    buffer.writeu8(b,offset,value)
end

function Kernel.get(b:buffer, offset:number):number
    return buffer.readu8(b,offset)
end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations
---------------------------------------------------------------------------------------------------

local function steped_fill(b: buffer, offset: number, value: number, count: number, step:number)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * step

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, value)
    end
end

local buffer_fill = buffer.fill
function Kernel.fill(b: buffer, offset: number, value: number, count: number, step:number?)
    if (step) then
        steped_fill(b,offset,value,count,step)
        return
    end

    buffer.fill(b,offset,value,count)

end

---------------------------------------------------------------------------------------------------
-- Scalar Transformations By Math Operators
---------------------------------------------------------------------------------------------------

function Kernel.addS(b: buffer, offset: number, scalar: number, count: number,step: number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, buffer.readu8(b, pointer) + scalar)
    end
end

function Kernel.mulS(b: buffer, offset: number, scalar: number, count: number,step: number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, buffer.readu8(b, pointer) * scalar)
    end
end

function Kernel.idivS(b: buffer, offset: number, scalar: number, count: number,step: number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, buffer.readu8(b, pointer) // scalar)
    end
end

function Kernel.modS(b: buffer, offset: number, scalar: number, count: number,step: number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, buffer.readu8(b, pointer) % scalar)
    end
end

function Kernel.powS(b: buffer, offset: number, scalar: number, count: number,step: number?)
    local _size = offset+count*item_size
    _size -=item_size

    local stepFactor = item_size * (step or 1)

    for pointer = offset, _size,stepFactor do
        buffer.writeu8(b, pointer, buffer.readu8(b, pointer) ^ scalar)
    end
end

return Kernel