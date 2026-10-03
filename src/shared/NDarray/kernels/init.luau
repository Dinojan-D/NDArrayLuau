--[=[
    ===============================================================================
                                   Kernel Registry
    ===============================================================================

    PRIVATE USE

    Maintains the registry of computation kernels used by NDArray.

    Each kernel implements optimized low-level operations for one or more
    numerical data types.
]=]

local types = require(script.Parent.types)

--[=[
    PRIVATE USE

    Maintains the registry of computation kernels used internally by NDArray.

    A kernel provides optimized implementations of numerical operations for
    one or more data types.
]=]
local Kernels = {}

--[=[
    PRIVATE USE

    Maps a kernel identifier to its implementation.
]=]
Kernels._kernelRegistry = {} :: {[types.DtypeName]:types.Kernel}

---------------------------------------------------------------------------------------------------
-- Register Zone
---------------------------------------------------------------------------------------------------

--auto register

for _, child in script:GetChildren() do
    if not child:IsA("ModuleScript") or not child.Name:match("%.kernel$") then
        continue
    end
    
    local dtype = string.split(child.Name, ".kernel")[1] :: types.DtypeName
    
    Kernels._kernelRegistry[dtype] = require(child) 

end



---------------------------------------------------------------------------------------------------
--  API
---------------------------------------------------------------------------------------------------
--[=[
    PRIVATE USE

    Returns the kernel associated with the specified data type.

    @param dtype : Data type (e.g. "i8", "u16", "f32") from DType.Enum.
    @return Kernel : Kernel implementing operations for the specified data type.
]=]
function Kernels.GetKernel(dtype:types.DtypeName)
    return Kernels._kernelRegistry[dtype]
end

return Kernels