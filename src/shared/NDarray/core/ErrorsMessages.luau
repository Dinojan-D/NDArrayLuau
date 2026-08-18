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



return ErrorsMessages