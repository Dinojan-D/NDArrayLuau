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
local kernels = require(script.kernels)
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

        error(ErrorsMessages.BufferMismatch(expectedBytes, buffer_len(buffer)),2)
    end

    if (strides and #strides ~= #shape) then
        error(ErrorsMessages.StridesMismatch(#shape, #strides),2)
    end

    self.shape = shape
    self.offset = offsets or 0
    self.size = size
    self.strides = strides or Utils.computeStridesFromShape(shape)
    self.ndim = #shape
    self.dtypeMetadata = dtypeMetadata
    self.nbytes = expectedBytes
    self._kernel = kernels.GetKernel(dtype)
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
    error(ErrorsMessages.Formatter("NotImplementedError", "Sorry this constructor is not implemented."),2)
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


---------------------------------------------------------------------------------------------------
-- Ndarray methods
---------------------------------------------------------------------------------------------------
--[=[
    Fills the entire array with a constant value.

    The value is validated against the current dtype range before being
    written into the underlying buffer.

    @param value : Value assigned to every element of the array.
]=]
function NDarray:fill(value:number)
    local max,min = self.dtypeMetadata.maxNumber,self.dtypeMetadata.minNumber

    if (value < min or value > max) then
        error(ErrorsMessages.ValueOutOfDTypeRange(value, self.dtypeMetadata.name, min, max,self.dtypeMetadata.valueType),2)
    end

    self._kernel.fill(self._buffer, self.offset, value, self.size)
end

--[=[
    Returns the value stored at a given coordinate.

    The coordinate must match the number of dimensions of the array and
    each index must be within the corresponding dimension bounds.

    Example:
        shape = {3, 4}

        array:getElement({1, 2})
        accesses the element at row 1, column 2.

    @param coordinate : N-dimensional coordinate of the element (0-indexing).
    @return number : Value stored at the given coordinate.
]=]
function NDarray:getElement(coordinate:{number}):number
    coordinate = table.clone(coordinate)

    if (not Utils.isValidCoordinate(coordinate, self.shape)) then
        error(ErrorsMessages.InvalidCoordinate(coordinate, self.shape),2)
    end

    local index1D = Utils.computeRowMajorIndex(coordinate, self.strides) *  self.dtypeMetadata.itemSize
    return self._kernel.get(self._buffer,index1D)
end

--[=[
    Sets the value at a given coordinate.

    The coordinate must match the number of dimensions of the array and
    each index must be within the corresponding dimension bounds.

    The assigned value must be representable by the array dtype.

    Example:
        shape = {3, 4}

        array:setElement({1, 2}, 42)

    @param coordinate : N-dimensional coordinate of the element (0-indexing).
    @param value : New value assigned to the element.
]=]
function NDarray:setElement(coordinate:{number},value:number)
    coordinate = table.clone(coordinate)

    local max,min = self.dtypeMetadata.maxNumber,self.dtypeMetadata.minNumber

    if (value < min or value > max) then
        error(ErrorsMessages.ValueOutOfDTypeRange(value, self.dtypeMetadata.name, min, max,self.dtypeMetadata.valueType),2)
    end

    if (not Utils.isValidCoordinate(coordinate, self.shape)) then
        error(ErrorsMessages.InvalidCoordinate(coordinate, self.shape),2)
    end

    local index1D = Utils.computeRowMajorIndex(coordinate, self.strides) * self.dtypeMetadata.itemSize

    return self._kernel.set(self._buffer, index1D, value)
end

--[=[
    Returns a view of the array with axes transposed.

    The returned NDArray shares the same underlying buffer as the original. 
    The shape and strides are reversed, effectively swapping dimensions. 
    This is a O(N) (N is dimension of this array) operation as no data is copied.

    @return NDArray : A new view of the array with transposed dimensions.
]=]
function NDarray:transpose(): NDArray
    local newShape = {}
    local newStrides = {}

    for i = self.ndim, 1, -1 do
        table.insert(newShape, self.shape[i])
        table.insert(newStrides, self.strides[i])
    end
    local view = NDarray._new(newShape, self.dtypeMetadata.name,self.offset,self._buffer,newStrides)
    
    return view 
end


---------------------------------------------------------------------------------------------------
-- In-Place Operators  (Mutable) like +=, -=, *=, /=, //=, ^=, %=
---------------------------------------------------------------------------------------------------

function NDarray:_scalarInPlace(scalar:number,operation:"add" | "sub" | "mul" | "div" | "idiv" | "mod" | "pow")
    local max,min = self.dtypeMetadata.maxNumber,self.dtypeMetadata.minNumber

    if (scalar < min or scalar > max) then
        error(ErrorsMessages.ValueOutOfDTypeRange(scalar, self.dtypeMetadata.name, min, max,self.dtypeMetadata.valueType),2)
    end

    if (self.dtypeMetadata.valueType  ~= "float" and operation == "div") then
        operation = "idiv"
    end

    if ((operation == "idiv" or operation == "div" or operation == "mod") and scalar == 0 ) then
        error(ErrorsMessages.ZeroDivisionError(),2)
    end

    if (operation == "add") then
        self._kernel.addS(self._buffer, self.offset, scalar,self.size)
    elseif (operation == "sub") then
        self._kernel.addS(self._buffer, self.offset, -scalar,self.size)
    elseif (operation == "mul") then
        self._kernel.mulS(self._buffer, self.offset, scalar,self.size)
    elseif (operation == "div") then
        self._kernel.divS(self._buffer, self.offset, scalar,self.size)
    elseif (operation == "idiv") then
        self._kernel.idivS(self._buffer, self.offset, scalar,self.size)
    elseif (operation == "mod") then
        self._kernel.modS(self._buffer, self.offset,scalar,self.size)
    elseif (operation == "pow") then
        self._kernel.powS(self._buffer, self.offset,scalar,self.size)
    else
        --DEV Error (in normal case)
        error(ErrorsMessages.Formatter("SyntaxError", "Unsupported operands for %s.", operation),2)
    end
end


--[=[
    Adds a scalar or another NDArray to this array in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:iadd(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"add")
    end

    return self
end

--[=[
    Subtracts a scalar or another NDArray to this array in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:isub(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"sub")
    end

    return self
end

--[=[
    Multiplies this array by a scalar or another NDArray in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:imul(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"mul")
    end

    
    return self
end

--[=[
    Divides this array by a scalar or another NDArray in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:idiv(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"div") 
    end
    
    return self
end

--[=[
    Performs floor division on this array in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:iidiv(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"idiv")
    end

    
    return self
end

--[=[
    Raises every element of this array to the given power in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:ipow(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"pow")
    end

    
    return self
end

--[=[
    Computes the modulo of this array in-place.

    If an NDArray is provided, both arrays must have the same shape.

    @param scalar : A scalar value or an NDArray.
    @return ndarray : This NDArray.
]=]
function NDarray:imod(scalar:number|NDArray):NDArray
    if typeof(scalar) == "number" then
        self:_scalarInPlace(scalar,"mod")
    end

    
    return self
end

---------------------------------------------------------------------------------------------------
-- Out-of-place operator (Immutable) like B = A + B, B = A - B, B = A * B, B = A / B, B = A // B, B = A ^ B, B = A % B
---------------------------------------------------------------------------------------------------
function NDarray._operationOutOfPlace(left:any, right:any, operation:"add" | "sub" | "mul" | "div" | "idiv" | "mod" | "pow"): NDArray
    -- NDArray op scalar
    if getmetatable(left) == NDarray and typeof(right) == "number" then
        local copy = NDarray.copy(left)
        copy:_scalarInPlace(right,operation)

        return copy
    end

    -- scalar op NDArray
    if typeof(left) == "number" and getmetatable(right) == NDarray then
        error(ErrorsMessages.Formatter("SyntaxError","Scalar %s NDArray is not implemented yet.",operation ),2)
    end

    -- NDArray op NDArray
    if getmetatable(left::any) == NDarray and getmetatable(right) == NDarray then
        error(ErrorsMessages.Formatter("SyntaxError","NDArray %s NDArray is not implemented yet.",operation),2)
    end

    --DEV Error (in normal case)
    error(ErrorsMessages.Formatter("SyntaxError", "Unsupported operands for %s.", operation),2)
end

function NDarray.__add(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "add")
end

function NDarray.__sub(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "sub")
end

function NDarray.__mul(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "mul")
end


function NDarray.__div(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "div")
end


function NDarray.__idiv(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "idiv")
end


function NDarray.__pow(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "pow")
end


function NDarray.__mod(left:any, right:any)
    return NDarray._operationOutOfPlace(left, right, "mod")
end



export type NDArray = typeof(setmetatable({}::types.ndarray,NDarray))
return NDarray
