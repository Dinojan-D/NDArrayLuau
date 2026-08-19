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
local ErrorsMessages = require(script.Parent.ErrorsMessages)
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


--[=[
    Normalizes a slice object by filling in default values and validating types.

    Adapted directly from CPython's slice implementation (Objects/sliceobject.c).

    Defaults logic:
        • step: Defaults to 1.
        • start: Defaults to 0 (step > 0) or math.huge (step < 0).
        • stop: Defaults to math.huge (step > 0) or -math.huge (step < 0).

    @param slice : The slice table containing optional start, stop, step.
    @error TypeError : If any index is neither an integer nor nil.
    @error ValueError : If step is zero.
]=]
function Utils.unpackSlice(slice:types.Slices)
    if (slice.step == nil) then
        slice.step = 1
    else
        if (type(slice.step) ~= "number" or slice.step % 1 ~= 0) then error(ErrorsMessages.Formatter("TypeError","Slice indices must be integers number or nil."),2) end
        if (slice.step == 0) then error(ErrorsMessages.Formatter('ValueError',"Slice 'step' cannot be zero."),2) end
    end
    local step = slice.step :: number

    if (slice.start == nil) then
        slice.start = if (step < 0) then math.huge else 0
    else
        if (type(slice.start) ~= "number" or slice.start % 1 ~= 0) then error(ErrorsMessages.Formatter('TypeError',"Slice indices must be integers number or nil."),2) end
    end

    if (slice.stop == nil) then
        slice.stop = if (step < 0) then -math.huge else math.huge
    else
        if (type(slice.stop) ~= "number" or slice.stop % 1 ~= 0) then error(ErrorsMessages.Formatter('TypeError',"Slice indices must be integers number or nil."),2) end
    end

end

--[=[
    Computes the resulting length of a sliced dimension.

    Translates Python's canonical PySlice_GetIndicesEx indexing logic (Objects/sliceobject.c)
    to calculate element count after normalizing negative bounds and step directions.

    @param dim : Length of the target dimension.
    @param _slice : Slice descriptor to evaluate.
    @return number : Exact element count in the resulting slice.
]=]
function Utils.computeLenghtFromSlice(dim:number,_slice:types.Slices)
    Utils.unpackSlice(_slice)
    
    local slice = _slice :: {start:number,stop:number,step:number}

    if (slice.start < 0) then
        slice.start = slice.start + dim
        if (slice.start < 0) then
            slice.start = if (slice.step < 0) then -1 else 0
        end
    elseif (slice.start >= dim) then
        slice.start = if (slice.step < 0 ) then dim-1 else dim
    end

    if (slice.stop < 0) then
        slice.stop = slice.stop + dim;
        if (slice.stop < 0) then
            slice.stop = if (slice.step < 0) then -1 else 0;
        end
    elseif (slice.stop >= dim) then
        slice.stop = if (slice.step < 0) then dim - 1 else dim;
    end

    if (slice.step < 0) then
        if (slice.stop < slice.start) then
            return (slice.start - slice.stop - 1) // (-slice.step) + 1;
        end
    else 
        if (slice.start < slice.stop) then
            return (slice.stop - slice.start - 1) // slice.step + 1;
        end
    end

    return 0
end



return Utils   