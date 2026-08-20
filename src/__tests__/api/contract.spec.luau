local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local NDarray = require(ReplicatedStorage.Shared.NDarray)
local DType = require(ReplicatedStorage.Shared.NDarray.core.DType)
local ErrorsMessages = require(ReplicatedStorage.Shared.NDarray.core.ErrorsMessages)
local Utils = require(ReplicatedStorage.Shared.NDarray.core.Utils)
local types = require(ReplicatedStorage.Shared.NDarray.types)



local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect


describe("NDarray methods contract",function()
    
    describe("._new()",function()
        it ("should clone shape and strides to prevent reference mutation",function()
            local shape = {10}
            local strides = {2}
            local array = NDarray._new(shape,DType.Enum.i8,0,nil,strides)

            expect(array.strides).toEqual(strides)
            expect(array.strides).never.toBe(strides)

            expect(array.shape).toEqual(shape)
            expect(array.shape).never.toBe(shape)
        end)

        it ("should throw when given an invalid shape",function()
            --I recommend to see test of the Utils.isValidShape
            local shape = {} 
            expect(function()
                NDarray._new(shape,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape))

            local shape1 = {0} 
            expect(function()
                NDarray._new(shape1,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape1))

            local shape2 = {-1} 
            expect(function()
                NDarray._new(shape2,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape2))
        end)

        it ("should throw when shape and strides dimensions do not match",function()
            local strides = {1} -- 1D
            local shape = {2,2,2} --3D

            expect(function()
                NDarray._new(shape,DType.Enum.i8,0,nil,strides)
            end).toThrow(ErrorsMessages.StridesMismatch(#shape, #strides))
        end)

        it("should throw when buffer byte length does not match expected size", function()
            local invalidBuffer1 = buffer.create(2)
            local invalidBuffer2 = buffer.create(200)
            local shape = {10,10}
            expect(function()
                NDarray._new(shape, DType.Enum.i8, 0, invalidBuffer1)
            end).toThrow(ErrorsMessages.BufferMismatch(100, buffer.len(invalidBuffer1)))
            expect(function()
                NDarray._new(shape, DType.Enum.i8, 0, invalidBuffer2)
            end).toThrow(ErrorsMessages.BufferMismatch(100, buffer.len(invalidBuffer2)))
        end)

        it("should create a buffer based on the dimensions size",function()
            local shape1 = {2} --1D
            expect(buffer.len(NDarray._new(shape1, "i8")._buffer)).toBe(2)
            
            local shape2 = {3,3}--2D
            expect(buffer.len(NDarray._new(shape2, "i8")._buffer)).toBe(9)

            local shape3 = {3,3,3}--#3D
            expect(buffer.len(NDarray._new(shape3, "i8")._buffer)).toBe(27)
        end)
    end)

    describe.each({
        {name="ones",fillValue=1},
        {name="zeros",fillValue=0}
    })('.$name()',function(item)
        local name = item.name
        local fillValue = item.fillValue
        it(`should fill each elements by {fillValue}`,function()
            local array = NDarray[name]({3,3}, "i8")
            local b = array._buffer

            for pointer=0,buffer.len(b)-1 do
                expect(buffer.readi8(b, pointer)).toBe(fillValue)
            end
        end)

        it ("should clone shape to prevent reference mutation",function()
            local shape = {10}
            local array = NDarray[name](shape,DType.Enum.i8)
            expect(array.shape).toEqual(shape)
            expect(array.shape).never.toBe(shape)
        end)

        it ("should throw when given an invalid shape",function()
            --I recommend to see test of the Utils.isValidShape
            local shape = {} 
            expect(function()
                NDarray[name](shape,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape))

            local shape1 = {0} 
            expect(function()
                NDarray[name](shape1,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape1))

            local shape2 = {-1} 
            expect(function()
                NDarray[name](shape2,DType.Enum.i8 )
            end).toThrow(ErrorsMessages.InvalidShape(shape2))
        end)
    end)    

    describe(".copy()",function()
        it("should copy shape and strides to prevent reference mutation",function()
            local sourceArray = NDarray._new({1}, "i8",nil,nil,{1})
            
            local array = NDarray.copy(sourceArray)

            expect(array.strides).toEqual(sourceArray.strides)
            expect(array.strides).never.toBe(sourceArray.strides)

            expect(array.shape).toEqual(sourceArray.shape)
            expect(array.shape).never.toBe(sourceArray.shape)

        end)
        describe("should have the same properties",function()
            local sourceArray = NDarray._new({1}, "i8",nil,nil,{1})
            local array = NDarray.copy(sourceArray)

            it("dtype",function()
                expect(array.dtypeMetadata.name).toEqual(sourceArray.dtypeMetadata.name)
            end)
            it("offset",function()
                expect(array.offset).toEqual(sourceArray.offset)
            end)
        end)

        it("should copy buffer",function()
            local sourceArray = NDarray._new({10}, "i8",nil,nil,{1})
            local sourceBuffer = sourceArray._buffer
            
            for pointer=0,buffer.len(sourceBuffer)-1 do
                buffer.writei8(sourceBuffer, pointer, math.random(-128,127))
            end

            local targetBuffer = NDarray.copy(sourceArray)._buffer

            expect(buffer.len(targetBuffer)).toBe(buffer.len(sourceBuffer))

            for pointer=0,buffer.len(sourceBuffer)-1 do
                expect(buffer.readi8(sourceBuffer, pointer)).toBe(buffer.readi8(targetBuffer, pointer))
            end

        end)
    end)

    describe(".fromArray()",function()

    end)

    describe(":fill()", function()
        it("should fill all buffer elements with the given value", function()
            local array = NDarray._new({3, 3}, "i8")
            array:fill(42)

            local buf = array._buffer
            for pointer = 0, buffer.len(buf) - 1 do
                expect(buffer.readi8(buf, pointer)).toBe(42)
            end
        end)

        it("should throw when value is out of dtype range", function()
            local array = NDarray._new({2, 2}, "i8")
            local meta = array.dtypeMetadata

            -- Above max bound
            expect(function()
                array:fill(128)
            end).toThrow(ErrorsMessages.ValueOutOfDTypeRange(128, meta.name, meta.minNumber, meta.maxNumber))

            -- Below min bound
            expect(function()
                array:fill(-129)
            end).toThrow(ErrorsMessages.ValueOutOfDTypeRange(-129, meta.name, meta.minNumber, meta.maxNumber))
        end)
    end)

    describe(":getElement()", function()
        it("should return the value at the specified coordinate", function()
            local array = NDarray._new({2, 3}, "i8")
            
            -- Shape {2, 3} with strides {3, 1}
            --  {0, 1} -> Offset = (0 * 3) + (1 * 1) = 1
            buffer.writei8(array._buffer, 1, 42)

            expect(array:getElement({0, 1})).toBe(42)
        end)

        it("should throw when coordinate is out of bounds or has invalid dimensions", function()
            local array = NDarray._new({2, 3}, "i8")

            -- Out of bounds 
            local outOfBounds = {2, 0}
            expect(function()
                array:getElement(outOfBounds)
            end).toThrow(ErrorsMessages.InvalidCoordinate(outOfBounds, array.shape))

            -- Dimension mismatch 
            local wrongDimensions = {0}
            expect(function()
                array:getElement(wrongDimensions)
            end).toThrow(ErrorsMessages.InvalidCoordinate(wrongDimensions, array.shape))
        end)
    end)

    describe(":setElement()", function()
        it("should set the value at the specified coordinate", function()
            local array = NDarray._new({2, 3}, "i8")
            
            -- Shape {2, 3} with strides {3, 1}
            --{0, 1} -> Offset = (0 * 3) + (1 * 1) = 1
            array:setElement({0, 1}, 42)

            expect(buffer.readi8(array._buffer, 1)).toBe(42)
        end)

        it("should throw when coordinate is out of bounds or has invalid dimensions", function()
            local array = NDarray._new({2, 3}, "i8")

            -- Out of bounds 
            local outOfBounds = {2, 0}
            expect(function()
                array:setElement(outOfBounds, 10)
            end).toThrow(ErrorsMessages.InvalidCoordinate(outOfBounds, array.shape))

            -- Dimension mismatch
            local wrongDimensions = {0}
            expect(function()
                array:setElement(wrongDimensions, 10)
            end).toThrow(ErrorsMessages.InvalidCoordinate(wrongDimensions, array.shape))
        end)

        it("should throw when value is out of dtype range", function()
            local array = NDarray._new({2, 2}, "i8")
            local meta = array.dtypeMetadata

            -- Above max bound
            expect(function()
                array:setElement({0, 0}, 128)
            end).toThrow(ErrorsMessages.ValueOutOfDTypeRange(128, meta.name, meta.minNumber, meta.maxNumber))

            -- Below min bound
            expect(function()
                array:setElement({0, 0}, -129)
            end).toThrow(ErrorsMessages.ValueOutOfDTypeRange(-129, meta.name, meta.minNumber, meta.maxNumber))
        end)
    end)

    describe(":transpose()",function()
        it("should not copy the buffer (zeo-copy)",function()
            local array = NDarray._new({10,10}, "i8")
            local transpose = array:transpose()

            expect(transpose._buffer).toBe(array._buffer)
        end)
        describe("should have the same properties",function()
            local sourceArray = NDarray._new({1}, "i8",nil,nil,{1})
            local array = sourceArray:transpose()

            it("offset",function()
                expect(array.offset).toEqual(sourceArray.offset)
            end)
            it("ndim",function()
                expect(array.ndim).toEqual(sourceArray.ndim)
            end)
            it("size",function()
                expect(array.size).toEqual(sourceArray.size)
            end)
            it("dtype",function()
                expect(array.dtypeMetadata.name).toEqual(sourceArray.dtypeMetadata.name)
            end)
            it("offset",function()
                expect(array.offset).toEqual(sourceArray.offset)
            end)
            it("contiguous",function()
                expect(array.contiguous).toEqual(sourceArray.contiguous)
            end)
        end)
        it("should correctly map coordinates and propagate mutations bidirectionally", function()
            local array = NDarray._new({2, 3}, "i8") -- Shape {2, 3}, Strides {3, 1}
            local transposed = array:transpose()     -- Shape {3, 2}, Strides {1, 3}

            array:setElement({1, 2}, 99)
            expect(transposed:getElement({2, 1})).toBe(99)

            transposed:setElement({0, 1}, 42)
            expect(array:getElement({1, 0})).toBe(42)
        end)

        it("should preserve 1D array structure", function()
            local array = NDarray._new({5}, "i8")
            local transposed = array:transpose()

            expect(transposed.shape).toEqual({5})
            expect(transposed.strides).toEqual(array.strides)
        end)
    end)

end)
