--[=[
    ===============================================================================
                                    DType Module
    ===============================================================================

    Provides metadata describing every numerical data type supported by NDArray.

    This module exposes:
        • The list of supported data types.
        • Immutable metadata for each data type.
        • Utilities for retrieving data type information.

    This module is part of the public NDArray API.
]=]

local types = require(script.Parent.Parent.types)

--[=[
    Provides metadata and utilities for the numerical data types supported
    by NDArray.

    This module defines:
    - the list of supported data types (`DType.Enum`);
    - immutable metadata associated with each data type;
    - helper functions for retrieving data type information.
]=]
local DType = {}

--[=[
    Enumeration of all data types supported by NDArray.
]=]
DType.Enum = {
    i8 = "i8",
    u8 = "u8",
    i16 = "i16",
    u16 = "u16",
    i32 = "i32",
    u32 = "u32",
    f32 = "f32",
    f64 = "f64"
} :: {[string]: types.DtypeName}

--[=[
    PRIVATE USE

    Immutable metadata describing each supported data type.
]=]
DType._Metadata = {
    i8 = {
        name = "i8",
        itemSize = 1,
        maxNumber = 127,
        minNumber = -128,
        valueType = "signed"
    },

    u8 = {
        name = "u8",
        itemSize = 1,
        maxNumber = 255,
        minNumber = 0,
        valueType = "unsigned"
    },

    i16 = {
        name = "i16",
        itemSize = 2,
        maxNumber = 32767,
        valueType = "signed"
        
    },

    u16 = {
        name = "u16",
        itemSize = 2,
        maxNumber = 65535,
        minNumber = 0,
        valueType = "unsigned"
    },

    i32 = {
        name = "i32",
        itemSize = 4,
        maxNumber = 2147483647,
        minNumber = -2147483648,
        valueType = "signed"
    },

    u32 = {
        name = "u32",
        itemSize = 4,
        maxNumber = 4294967295,
        minNumber = 0,
        valueType = "unsigned"
    },

    f32 = {
        name = "f32",
        itemSize = 4,
        maxNumber = 3.402823466e+38,
        minNumber = -3.402823466e+38,
        valueType = "float"
    },

    f64 = {
        name = "f64",
        itemSize = 8,
        maxNumber = 1.7976931348623157e+308,
        minNumber = -1.7976931348623157e+308,
        valueType = "float"
    }

}::{[types.DtypeName]: types.DtypeMetadata}

table.freeze(DType._Metadata)
for _, object in pairs(DType._Metadata) do
    table.freeze(object)
end
table.freeze(DType.Enum)

--[=[
    Returns the metadata associated with a data type.

    The returned object is immutable and must not be modified.

    @param dtype : Data type (e.g. DType.Enum.i8).
    @return DtypeObject : Metadata describing the specified data type.
]=]
function DType.getDtypeMetadata(dtype:types.DtypeName):types.DtypeMetadata
    return DType._Metadata[dtype]
end

return DType