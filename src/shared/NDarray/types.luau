--[=[
    ===============================================================================
                                    Types Module
    ===============================================================================

    This module contains every special types of this project

]=]

--[=[
    Represents an n-dimensional array.

    Conventions:
    - offset : Byte offset into the buffer. 
    In normal case this must be aligned to the dtype's item size.
    => offset % itemSize == 0

]=]
export type ndarray = {
    -- Raw contiguous memory storing the array elements.
    _buffer: buffer,

    -- Size of each dimension.
    shape: {number},

    -- Memory stride for each dimension.
    strides: {number},

    -- Total number of elements.
    size: number,

    -- Number of dimensions.
    ndim: number,

    -- Total size in bytes.
    nbytes: number,

    -- Data type metadata.
    dtypeMetadata: DtypeMetadata,

    -- Optimized kernel for this dtype.
    _kernel: Kernel,

    -- Offset, in bytes, that point the beginning of the buffer.
    offset: number,

    -- Indicates whether the elements in the buffer are contiguous (in case of views).
    contiguous:boolean,
}
--[=[
    A union type representing the supported data types for NDArray elements.
]=]
export type DtypeName = "i8" | "u8" | "i16" | "u16" | "i32" | "u32" | "f16" | "f32" | "f64"

--[=[
    A union type representing the supported sign and representation categories for dtypes.
]=]
export type DTypeValueType = "unsigned" | "signed" | "float"

--[=[
    Describes the properties of a numerical data type supported by NDArray.

    A dtypeMetadata defines how values are represented in memory and the
    numerical range supported by the data type.
]=]
export type DtypeMetadata = {
    -- Name of the data type (e.g. "i8", "u16", "f32").
    name: DtypeName,

    -- Size of one element in bytes.
    itemSize: number,

    -- Largest representable value.
    maxNumber: number,

    -- Smallest representable value.
    minNumber: number,

    -- The sign and representation category of the data type.
    valueType:("unsigned" | "signed" | "float")
}

--[=[
    Defines the interface implemented by all computation kernels.

    A kernel performs low-level numerical operations directly on a raw buffer.
    All offsets and counts are expressed in bytes.

    Conventions:
    - offset : Byte offset into the buffer. 
    In normal case this must be aligned to the dtype's item size.
    => offset % itemSize == 0

    - count  : Number of elements to process from offset.
    If omitted, the operation processes the remainder of the buffer.
    => offset + count * itemSize <= buffer.len(buffer)

]=]
export type Kernel = {

    -- Fills the buffer with a constant value.
    fill: (b: buffer, offset: number, value: number, count: number?) -> (),

    -- Sets the value to the given index in the buffer.
    set:(b:buffer, offset:number, value:number) -> (),

    -- Gets the value at the given index in the buffer.
    get:(b:buffer, offset:number) -> (number),

---{Arithmetic scalar operators}------------------------------------------------------------------------------------------------
    -- Adds a scalar to each element.
    addS: (b: buffer, offset: number, scalar: number, count: number?) -> (),

    -- Multiplies each element by a scalar.
    mulS: (b: buffer, offset: number, scalar: number, count: number?) -> (),

    -- Performs integer (floor) division by a scalar.
    idivS: (b: buffer, offset: number, scalar: number, count: number?) -> (),

    -- Raises each element to a scalar power.
    powS: (b: buffer, offset: number, scalar: number, count: number?) -> (),

    -- Computes the modulo with a scalar.
    modS: (b: buffer, offset: number, scalar: number, count: number?) -> (),

}


return {}