local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local NDarray = require(ReplicatedStorage.Shared.NDarray)
local DType = require(ReplicatedStorage.Shared.NDarray.core.DType)
local ErrorsMessages = require(ReplicatedStorage.Shared.NDarray.core.ErrorsMessages)
local Utils = require(ReplicatedStorage.Shared.NDarray.core.Utils)
local types = require(ReplicatedStorage.Shared.NDarray.types)
local KernelContexts = require(ReplicatedStorage.tests.contexts.KernelContexts)
local KernelOracle = require(ReplicatedStorage.tests.contexts.KernelOracle)

local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach

local function castValue(meta: types.DtypeMetadata, value: number): number
    local bitSize = meta.itemSize * 8

    if meta.valueType == "signed" then
        return Utils.castI(bitSize, value)
    elseif meta.valueType == "unsigned" then
        return Utils.castU(bitSize, value)
    end

    -- Pour "float" (f32/f64), pas de wrap-around binaire
    return value
end

describe.each(KernelContexts.getAvaiablesKernels())("Kernel contract: $name", function(kernelInfo: KernelContexts.KernelDescprition)
    local metaDtype = DType.getDtypeMetadata(kernelInfo.name)
    local itemSize = metaDtype.itemSize
    local bufferElement = 10
    local bufferSize = itemSize * bufferElement
    local cast = DType.getCaster(kernelInfo.name)    

    local b: buffer
    local kernel: types.Kernel

    beforeEach(function()
        b = buffer.create(bufferSize)
        kernel = KernelContexts.mockedKernel(kernelInfo.name)
    end)

    describe(".set() & get()", function()
        it.each({
            { offset = 0, pos = "start" },
            { offset = (bufferElement // 2) * itemSize, pos = "middle" },
            { offset = bufferSize - itemSize, pos = "end" },
        })("should write the value at the given byte offset: $pos", function(item)
            local value = 1
            kernel.set(b, item.offset, value)

            for pointer = 0, bufferSize - itemSize, itemSize do
                local received = kernel.get(b, pointer)
                if pointer == item.offset then
                    expect(received).toBe(value)
                else
                    expect(received).toBe(0)
                end
            end
        end)
    end)

    describe.each({
        { name = "fill", compute = function(orig, scalar) return scalar end },
        { name = "addS", compute = function(orig, scalar) return orig + scalar end },
        { name = "mulS", compute = function(orig, scalar) return orig * scalar end },
        { name = "idivS", compute = function(orig, scalar) return orig // scalar end },
        { name = "modS", compute = function(orig, scalar) return orig % scalar end },
        { name = "powS", compute = function(orig, scalar) return orig ^ scalar end },
    })(".$name()", function(item)
        describe("offset/count window isolation", function()
            it("should only mutate excluding the first & last", function()
                local defaultValue = 3
                KernelOracle.fillBuffer(b, kernelInfo.name, defaultValue)

                local transValue = 5
                local offset = itemSize -- we start a the seconde element

                -- we count the amount of element to go from the start index to the last
                -- the first element start at the seconde element of the buffer so we can remove 1
                -- and remove again one for the last
                local count = bufferElement-2 -- we count the amount of element to go from the start index to the last

                kernel[item.name](b, offset, transValue, count)

                expect(kernel.get(b, 0)).toBe(defaultValue)
                expect(kernel.get(b, bufferSize - itemSize)).toBe(defaultValue)

                for pointer = 0, bufferSize - itemSize, itemSize do
                    local received = kernel.get(b, pointer)
                    if pointer >= offset and pointer < (offset + count * itemSize) then
                        expect(received).toBe(cast(item.compute(cast(defaultValue), transValue)))
                    else
                        expect(received).toBe(defaultValue)
                    end
                end
            end)

            it("should exclude everything when count is 0", function()
                local defaultValue = 3
                KernelOracle.fillBuffer(b, kernelInfo.name, defaultValue)

                local transValue = 5
                local byteOffset = 0
                local count = 0

                kernel[item.name](b, byteOffset, transValue, count)

                for pointer = 0, bufferSize - itemSize, itemSize do
                    local received = kernel.get(b, pointer)
                    expect(received).toBe(defaultValue)
                end
            end)

            it.each({
                { offset = 0, pos = "start" },
                { offset = (bufferElement // 2) * itemSize, pos = "middle" },
                { offset = bufferSize - itemSize, pos = "end" },
            })("should only mutate the $pos", function(testItem)
                local defaultValue = 3
                KernelOracle.fillBuffer(b, kernelInfo.name, defaultValue)

                local transValue = 5
                local offset = testItem.offset
                kernel[item.name](b, offset, transValue, 1)

                for pointer = 0, bufferSize - itemSize, itemSize do
                    local received = kernel.get(b, pointer)
                    if pointer == offset then
                        expect(received).toBe(cast(item.compute(cast(defaultValue), transValue)))
                    else
                        expect(received).toBe(defaultValue)
                    end
                end
            end)
        end)
        it("should mutate the complete buffer",function()
            local defaultValue = 3
            KernelOracle.fillBuffer(b, kernelInfo.name, defaultValue)

            local transValue = 5
            local offset = 0 

            local count = bufferElement

            kernel[item.name](b, offset, transValue, count)

            for pointer = 0, bufferSize - itemSize, itemSize do
                local received = kernel.get(b, pointer)
                expect(received).toBe(cast(item.compute(cast(defaultValue), transValue)))
            end
        end)
    end)
end)