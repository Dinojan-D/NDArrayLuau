--[=[
    ===============================================================================
                                   Internal Module
    ===============================================================================

    PRIVATE USE

    This module is used internally by the NDArray implementation and is not
    intended to be accessed directly by users.

    Responsibility:
        • Row-Major-order functions
        • Slincing functions
        • Checking functions 
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local types = require(ReplicatedStorage.Shared.NDarray.types)


--[=[
    PRIVATE USE

    Collection of internal utility functions used throughout the NDArray
    implementation.
]=]
local Utils = {}

--[=[
    Returns whether a shape is valid.

    A shape is valid if:
        • It contains at least one dimension.
        • Every dimension is strictly greater than zero.

    Examples:
        {3}         -> true
        {2, 4, 5}   -> true
        {}          -> false
        {2, 0, 4}   -> false
        {2, -1, 4}  -> false
        {2, 1.1, 4}   -> false

    @param shape : Shape to validate.
    @return boolean : True if the shape is valid.
]=]
function Utils.isValidShape(shape: {number}): boolean
    local ndim = #shape

    if ndim == 0 then
        return false
    end

    for i = 1, ndim do
        if shape[i] <= 0 or shape[i]%1 ~=0 then
            return false
        end
    end

    return true
end


--[=[
    Computes the total number of elements for a given shape.

    @param shape : Shape of the array.
    @return number : Total number of elements.
]=]
function Utils.computeSizeFromShape(shape:{number})
    local size = 1
    for _,dim in shape do
        size *= dim
    end
    return size
end

--[=[
    Computes the row-major strides associated with a shape.

    For example:
        shape = {2, 3, 4}
        strides = {12, 4, 1}

    @param shape : Shape of the array.
    @return {number} : Row-major strides.
]=]
function Utils.computeStridesFromShape(shape:{number})
    local ndim = #shape
    local strides = {}
    local stride = 1
    for i = ndim,1,-1 do
        strides[i] = stride
        stride *= shape[i]
    end
    return strides
end


--[=[
    Computes the row-major linear index associated with a coordinate.

    This function assumes that:
        • coords and strides have the same length.
        • Coordinates are valid.

    Formula:
        index = Σ((coords[i]) * strides[i])
    
    @param coords : Coordinate in the array (0-indexing).
    @param strides : Row-major strides.
    @return number : Linear element index.
]=]
function Utils.computeRowMajorIndex(coords: {number}, strides: {number}): number
    local index = 0

    for i = 1, #strides do
        index += (coords[i]) * strides[i]
    end

    return index
end


--[=[
    Returns whether a coordinate is valid for the given shape.

    A coordinate is valid if:
        • It has the same number of dimensions as the shape.
        • Every coordinate satisfies:
            0 <= coord[i] <= shape[i]-1

    @param coords : Coordinate to validate (0-indexing).
    @param shape : Target array shape.
    @return boolean : True if the coordinate is valid.
]=]
function Utils.isValidCoordinate(coords: {number}, shape: {number}): boolean
    local ndim = #shape

    if #coords ~= ndim then
        return false
    end

    for i = 1, ndim do
        local coord = coords[i]

        if coord < 0 or coord > shape[i]-1 then
            return false
        end
    end

    return true
end

--[=[
    Returns whether a tensor is contiguous in memory (row-major).

    Is contiguous if elements are stored sequentially without gaps,
    where the rightmost dimension has stride 1 and each preceding stride 
    equals the product of the following dimension sizes.
    Dimensions with size 1 are ignored as they do not affect memory layout.

    @param shape : Target array shape.
    @param strides : Array strides to evaluate.
    @return boolean : True if the layout is contiguous in memory.
]=]
function Utils.isContiguous(shape:{number},strides:{number}):boolean
    local expectedStrides = 1
    for i = #strides,1,-1 do
        local dimSize = shape[i]

        if dimSize == 1 then
            continue
        end

        if (strides[i] ~= expectedStrides) then return false end
        expectedStrides *= dimSize
    end
    
    return true
end


return Utils   