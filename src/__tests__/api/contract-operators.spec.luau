local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local NDarray = require(ReplicatedStorage.Shared.NDarray)
local DType = require(ReplicatedStorage.Shared.NDarray.core.DType)
local ErrorsMessages = require(ReplicatedStorage.Shared.NDarray.core.ErrorsMessages)
local Utils = require(ReplicatedStorage.Shared.NDarray.core.Utils)
local types = require(ReplicatedStorage.Shared.NDarray.types)
local KernelContexts = require(ReplicatedStorage.tests.contexts.KernelContexts)



local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local DEFAULT_DTYPE = DType.Enum.f64

type MethodDescription = {
    callName: string,
    action: string,
    kernelMethod: string,
    transformScalar: ((scalar: number) -> number)?,
}

local InPlaceOperators: {MethodDescription} = {
    {callName = "iadd",  action = "addition",       kernelMethod = "addS"},
    {callName = "isub",  action = "subtract",       kernelMethod = "addS",  transformScalar = function(s) return -s end},
    {callName = "imul",  action = "multiply",       kernelMethod = "mulS"},
    {callName = "idiv",  action = "division",       kernelMethod = "mulS",  transformScalar = function(s) return 1 / s end},
    {callName = "iidiv", action = "floor division", kernelMethod = "idivS"},
    {callName = "imod",  action = "modulo",         kernelMethod = "modS"},
    {callName = "ipow",  action = "power",          kernelMethod = "powS"},
}

describe("NDarray contract test : InPlace Scalar operators", function()
    describe.each(InPlaceOperators)(":$callName()", function(method: MethodDescription)
        it(`should {method.action} using kernel.{method.kernelMethod}`, function()
            local array = NDarray.zeros({2, 2}, DEFAULT_DTYPE)
            array._kernel = KernelContexts.mockedKernel(DEFAULT_DTYPE)
            
            local inputScalar = 2
            local expectedScalar = if method.transformScalar 
                then method.transformScalar(inputScalar) 
                else inputScalar

            array[method.callName](array, inputScalar)
            
            local mock = array._kernel[method.kernelMethod]
            
            expect(mock).toHaveBeenCalledTimes(1)
            
            local args = mock.mock.calls[1]
            expect(args[1] == array._buffer).toBe(true)
            expect(args[2]).toBe(array.offset)
            expect(args[3]).toBe(expectedScalar)
            expect(args[4]).toBe(array.size)
        end)
    end)

    describe.each({
        {callName = "idiv",action="division"},
        {callName = "iidiv", action = "floor division"},
        {callName = "imod",  action = "modulo"}})(":$callName()", function(method: MethodDescription)
            it(`should throw an error if {method.action} by 0`,function()
                local array = NDarray.zeros({2, 2}, DEFAULT_DTYPE)
                expect(function()
                    array[method.callName](array,0)
                end).toThrow(ErrorsMessages.ZeroDivisionError())
            end)
        end)

    describe(":idiv()",function()
        it("should be a floor division for integrer types",function()
            local array = NDarray.zeros({2, 2}, "i8")
            array._kernel = KernelContexts.mockedKernel("i8")
            
            local inputScalar = 2


            array:idiv(inputScalar)
            
            local mock = array._kernel.idivS
            
            expect(mock).toHaveBeenCalledTimes(1)
            
            local args = mock.mock.calls[1]
            expect(args[1] == array._buffer).toBe(true)
            expect(args[2]).toBe(array.offset)
            expect(args[3]).toBe(inputScalar)
            expect(args[4]).toBe(array.size)
        end)
    end)

end)