--[=[
    ===============================================================================
                                    Errors Messages Module
    ===============================================================================

    PRIVATE USE

    Centralizes error formatting and standardizes error messages across the library.
    It uses a Python-inspired naming convention (ValueError, IndexError, etc.) to 
    provide clear, consistent, and actionable feedback to developers.

    It provides:
        • A standard message formatter with name of this library.
        • Predefined error types for common issues.


    This module is part of the internal NDarray usage and is not intended for public consumption.
]=]


local ErrorsMessages = {}

type ErrorType = "ValueError" | "IndexError" | "TypeError" | "NotImplementedError" | "RuntimeError" | "AssertionError" | "MemoryError" | "OverflowError" | "UnderflowError" | "ZeroDivisionError" | "AttributeError" | "KeyError" | "ImportError" | "NameError" | "SyntaxError" | "IndentationError" | "TabError" | "SystemExit" | "KeyboardInterrupt"


local function tableToString(t):string
    return "{"..table.concat(t,",").."}"
end


--[=[
    PRIVATE USE

    Formats an NDArray error message by prepending the standard library prefix.

    @param errorType : The type of the error.
    @param message : Format string.
    @param ... : Values passed to string.format().
    @return string : Formatted error message.
]=]
function ErrorsMessages.Formatter(errorType:ErrorType,message:string,...):string
    return "["..errorType.."] "..string.format(message,...)
end

function ErrorsMessages.InvalidShape(shape: {number}): string
    return ErrorsMessages.Formatter(
        'ValueError', "Invalid shape %s. Each dimension must be a strictly positive integer.",
        tableToString(shape)
    )
end

function ErrorsMessages.BufferMismatch(expected: number, got: number): string
    return ErrorsMessages.Formatter(
        "ValueError","Buffer size mismatch. Expected %d bytes, got %d bytes.",
        expected,
        got
    )
end

function ErrorsMessages.StridesMismatch(expected:number,got:number):string
    return ErrorsMessages.Formatter("ValueError","Number of strides (%d) must match shape rank (%d).",got,expected)
end


function ErrorsMessages.ValueOutOfDTypeRange(value:number, dtype:number, min:number, max:number):string
    return ErrorsMessages.Formatter(
        "OverflowError","Value %g is out of range for dtype '%s'. Expected [%g, %g].",
        value,
        dtype,
        min,
        max
    )
end

function ErrorsMessages.InvalidCoordinate(coordinate:{number},shape:{number})
    return ErrorsMessages.Formatter(
        "IndexError","Coordinate %s is incompatible with shape %s.",
        tableToString(coordinate),
        tableToString(shape)
    )
end

return ErrorsMessages