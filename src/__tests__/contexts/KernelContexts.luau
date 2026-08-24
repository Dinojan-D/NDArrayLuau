local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local kernels = require(ReplicatedStorage.Shared.NDarray.kernels)
local types = require(ReplicatedStorage.Shared.NDarray.types)

local jest = JestGlobals.jest

local KernelContexts = {}
function KernelContexts.mockedKernel(dtype: types.DtypeName): types.Kernel
    local realKernel = kernels.GetKernel(dtype)

    return {
        fill = jest.fn(realKernel.fill),
        get = jest.fn(realKernel.get),
        set = jest.fn(realKernel.set),
        addS = jest.fn(realKernel.addS),
        mulS = jest.fn(realKernel.mulS),
        divS = jest.fn(realKernel.divS),
        idivS = jest.fn(realKernel.idivS),
        modS = jest.fn(realKernel.modS),
        powS = jest.fn(realKernel.powS),
    } :: any
end



return KernelContexts