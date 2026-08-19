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
local DType = require(script.core.DType)
local ErrorsMessages = require(script.core.ErrorsMessages)
local Utils = require(script.core.Utils)
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

---------------------------------------------------------------------------------------------------
-- ndarray constructors 
---------------------------------------------------------------------------------------------------

--[=[
    PRIVATE USE

    Create a new NDarray of given shape and type, filled with zeros.
    Any Objects provided in arguments will be unpersistant for security.

    @param shape :  Shape of the new array, e.g., (2, 3) or 2 (tuple of 'int(s)').
    @param dtype : The desired data-type for the array, e.g., DType.Enum.i8 , DType.Enum.u8.
    @param b : (Optional) A pre-allocated buffer to be used by the array. 
               If provided, the buffer size must exactly match the product 
               of the shape and the item size(in bytes) of the dtype. If nil, a new 
               buffer will be automatically allocated and initialized to zero.
    @return ndarray : Array of zeros with the given shape, dtyp.
]=]
function NDarray._new(shape:{number},dtype:types.DtypeName,offsets:number?,buffer:buffer?,strides:{number}?)
    local self = setmetatable({}::types.ndarray,NDarray)

    shape = table.clone(shape)
    strides = if (strides) then table.clone(strides) else nil

    if (not Utils.isValidShape(shape)) then
        error(ErrorsMessages.InvalidShape(shape),2)
    end

    local size = Utils.computeSizeFromShape(shape)
    local dtypeMetadata = DType.getDtypeMetadata(dtype)
    local expectedBytes = size * dtypeMetadata.itemSize

    if (buffer and buffer_len(buffer) ~= expectedBytes) then
        error(ErrorsMessages.BufferMismatch(expectedBytes, buffer_len(buffer)))
    end

    if (strides and #strides ~= #shape) then
        error(ErrorsMessages.StridesMismatch(#shape, #strides))
    end

    self.shape = shape
    self.offset = offsets or 0
    self.size = size
    self.strides = strides or Utils.computeStridesFromShape(shape)
    self.ndim = #shape
    self.dtypeMetadata = dtypeMetadata
    self.nbytes = expectedBytes
    self._kernel = {}
    self._buffer = buffer or create_buffer(self.nbytes)
    self.contiguous = Utils.isContiguous(self.shape, self.strides)

    return self
end

--[=[
    Create a new NDarray of given shape and type, filled with ones.


    @param shape :  Shape of the new array, e.g., (2, 3) or 2 (tuple of 'int(s)').
    @param dtype : The desired data-type for the array, e.g., DType.Enum.i8 , DType.Enum.u8.
    @return ndarray : Array of ones with the given shape, dtyp.
]=]
function NDarray.ones(shape:{number},dtype:types.DtypeName):NDArray
    local self = NDarray._new(shape,dtype,0)
    self:fill(1)
    return self
end

--[=[
    Create a new NDarray of given shape and type, filled with zeros.


    @param shape :  Shape of the new array, e.g., (2, 3) or 2 (tuple of 'int(s)').
    @param dtype : The desired data-type for the array, e.g., DType.Enum.i8 , DType.Enum.u8.
    @return ndarray : Array of zeros with the given shape, dtyp.
]=]
function NDarray.zeros(shape:{number},dtype:types.DtypeName):NDArray
    local self = NDarray._new(shape,dtype,0)
    return self
end

--[=[
    Creates a new NDarray from a Lua n-dimensional table.

    The input table must have a uniform shape. The resulting array is
    allocated using the specified data type.

    @param object : A uniform n-dimensional Lua table.
    @param dtype : Data type of the resulting array.
    @return ndarray : A new NDArray containing the values from the input table.
]=]
function NDarray.fromArray(object,dtype:types.DtypeName):NDArray
    local shape = {}
    --to implement
    local self = NDarray._new(shape,dtype,0)

    return self
end

--[=[
    Creates a deep copy of an existing NDArray.

    The returned array owns its own buffer. Modifying the copy does not
    affect the original array.

    @param ndarray : Source NDArray to copy.
    @return ndarray : A new independent NDArray containing the same data.
]=]
function NDarray.copy(ndarray:NDArray):NDArray
    local self =  NDarray._new(ndarray.shape,ndarray.dtypeMetadata.name,ndarray.offset)
    buffer.copy(self._buffer,ndarray.offset,ndarray._buffer,ndarray.offset)
    return self
end

export type NDArray = typeof(setmetatable({}::types.ndarray,NDarray))
return NDarray
