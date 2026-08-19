local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Utils = require(ReplicatedStorage.Shared.NDarray.core.Utils)
local types = require(ReplicatedStorage.Shared.NDarray.types)



local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect


describe("Utils.isValidShape", function()
    it("should return false for negative dimensions", function()
        expect(Utils.isValidShape({-1})).toBe(false)
        expect(Utils.isValidShape({3, 4, -1})).toBe(false)
        expect(Utils.isValidShape({2, -1, 4})).toBe(false)
    end)

    it("should return false for zero dimensions", function()
        expect(Utils.isValidShape({0})).toBe(false)
        expect(Utils.isValidShape({3, 0, 4})).toBe(false)
        expect(Utils.isValidShape({2, 0, 4})).toBe(false)
    end)

    it("should return false for non-integer dimensions", function()
        expect(Utils.isValidShape({1.5})).toBe(false)
        expect(Utils.isValidShape({3, 4, 2.7})).toBe(false)
        expect(Utils.isValidShape({2, 1, -2.1})).toBe(false)
    end)

    it("should return false for empty shape", function()
        expect(Utils.isValidShape({})).toBe(false)
    end)
end)

describe("Utils.computeStridesFromShape",function()
    it("vector 1D",function()
        expect(Utils.computeStridesFromShape({1})).toEqual({1})
        expect(Utils.computeStridesFromShape({10})).toEqual({1})
    end)
    it("matrix 2D",function()
        expect(Utils.computeStridesFromShape({1,1})).toEqual({1,1})
        expect(Utils.computeStridesFromShape({2,3})).toEqual({3,1})
        expect(Utils.computeStridesFromShape({4,5})).toEqual({5,1})
    end)
end)

describe("Utils.computeRowMajorIndex",function()
    local strides1D = Utils.computeStridesFromShape({10})
    local strides2D = Utils.computeStridesFromShape({10,10})
    local strides3D = Utils.computeStridesFromShape({10,10,10})


    it("should return linear index 0 for origin coordinates (0-indexed N-D)",function()
        expect(Utils.computeRowMajorIndex({0},strides1D)).toBe(0) -- for 1D tensor 
        expect(Utils.computeRowMajorIndex({0,0},strides2D)).toBe(0) -- for 2D tensor
        expect(Utils.computeRowMajorIndex({0,0,0},strides3D)).toBe(0) -- for 3D tensor
    end)
    it("should return (total_elements - 1) for the last valid N-D coordinate",function()
        expect(Utils.computeRowMajorIndex({9},strides1D)).toBe(10 - 1)-- for 1D tensor 
        expect(Utils.computeRowMajorIndex({9,9},strides2D)).toBe(10 * 10 - 1) -- for 2D tensor
        expect(Utils.computeRowMajorIndex({9,9,9},strides3D)).toBe(10 * 10 * 10 -1)-- for 3D tensor
    end)
    it("should use strides size as loop lenght for the computation.",function()
        expect(function()
            Utils.computeRowMajorIndex({0,0}, {1,1})
        end).never.toThrow()
    end)
end)

describe("Utils.isValidCoordinate", function()
    local shape2D = {10, 5} -- Dim 1 : [0..9], Dim 2 : [0..4]

    it("should return true for valid 0-indexed coordinates", function()
        expect(Utils.isValidCoordinate({0, 0}, shape2D)).toBe(true) 
        expect(Utils.isValidCoordinate({5, 2}, shape2D)).toBe(true)
        expect(Utils.isValidCoordinate({9, 4}, shape2D)).toBe(true)
    end)

    it("should return false if dimensions count does not match shape", function()
        expect(Utils.isValidCoordinate({0}, shape2D)).toBe(false) 
        expect(Utils.isValidCoordinate({0, 0, 0}, shape2D)).toBe(false) 
    end)

    it("should return false for negative coordinates", function()
        expect(Utils.isValidCoordinate({-1, 0}, shape2D)).toBe(false)
        expect(Utils.isValidCoordinate({0, -1}, shape2D)).toBe(false)
    end)

    it("should return false when reaching or exceeding shape size (1-indexing trap)", function()
        expect(Utils.isValidCoordinate({10, 0}, shape2D)).toBe(false)
        expect(Utils.isValidCoordinate({0, 5}, shape2D)).toBe(false)
        expect(Utils.isValidCoordinate({10, 5}, shape2D)).toBe(false)
    end)
end)

describe("Utils.isContiguous", function()
    it("should return true for standard contiguous shapes (1D, 2D, 3D)", function()
        expect(Utils.isContiguous({10}, {1})).toBe(true)
        expect(Utils.isContiguous({2, 3}, {3, 1})).toBe(true)
        expect(Utils.isContiguous({2, 3, 4}, {12, 4, 1})).toBe(true)
    end)

    it("should return false for non-contiguous layouts (e.g. transposed or sliced)", function()
        expect(Utils.isContiguous({2, 3}, {1, 2})).toBe(false)
        expect(Utils.isContiguous({2, 3}, {6, 2})).toBe(false)
    end)

    it("should ignore singleton dimensions (size 1) regardless of their stride", function()
        expect(Utils.isContiguous({1, 5, 1}, {5, 1, 1})).toBe(true)
        expect(Utils.isContiguous({1, 5, 1}, {99, 1, 42})).toBe(true)
    end)

    it("should return false if the last non-singleton dimension stride is not 1", function()
        expect(Utils.isContiguous({2, 3}, {6, 2})).toBe(false)
        expect(Utils.isContiguous({5}, {2})).toBe(false)
    end)

end)

describe("Utils.unpackSlice", function()
    it("should assign default values for an empty slice (equivalent to [:])", function()
        local slice = {}::types.Slices
        Utils.unpackSlice(slice)
        expect(slice.step).toBe(1)
        expect(slice.start).toBe(0)
        expect(slice.stop).toBe(math.huge)
    end)

    it("should assign default values for a negative step (equivalent to [::-1])", function()
        local slice = { step = -1 }::types.Slices
        Utils.unpackSlice(slice)
        expect(slice.step).toBe(-1)
        expect(slice.start).toBe(math.huge)
        expect(slice.stop).toBe(-math.huge)
    end)

    it("should throw an error if step is equal to 0", function()
        expect(function()
            Utils.unpackSlice({ step = 0 })
        end).toThrow()
    end)

    it("should throw an error if indices are not integers", function()
        expect(function() Utils.unpackSlice({ start = 1.5 }) end).toThrow()
        expect(function() Utils.unpackSlice({ start = "a" }) end).toThrow()
        expect(function() Utils.unpackSlice({ start = -2.1 }) end).toThrow()

        expect(function() Utils.unpackSlice({ step = 1.5 }) end).toThrow()
        expect(function() Utils.unpackSlice({ step = "a" }) end).toThrow()
        expect(function() Utils.unpackSlice({ step = -2.1 }) end).toThrow()

        expect(function() Utils.unpackSlice({ stop = 1.5 }) end).toThrow()
        expect(function() Utils.unpackSlice({ stop = "a" }) end).toThrow()
        expect(function() Utils.unpackSlice({ stop = -2.1 }) end).toThrow()
    end)

    it("should preserve explicit values", function()
        local slice = { start = 2, stop = 5, step = 2 }::types.Slices
        Utils.unpackSlice(slice)
        expect(slice.start).toBe(2)
        expect(slice.stop).toBe(5)
        expect(slice.step).toBe(2)
    end)

end)

describe("Utils.computeLenghtFromSlice", function()
    local DIM = 10

    it("should return total dimension for a full slice [:]", function()
        local slice = {}::types.Slices
        local length = Utils.computeLenghtFromSlice(DIM, slice)
        expect(length).toBe(10)
        expect(slice.start).toBe(0)
        expect(slice.stop).toBe(10)
    end)

    it("should compute length for a standard slice [2:7]", function()
        local length = Utils.computeLenghtFromSlice(DIM, { start = 2, stop = 7 })
        expect(length).toBe(5) -- Indices 2, 3, 4, 5, 6
    end)

    it("should handle step greater than 1 [1:8:2]", function()
        local length = Utils.computeLenghtFromSlice(DIM, { start = 1, stop = 8, step = 2 })
        expect(length).toBe(4) -- Indices 1, 3, 5, 7
    end)

    it("should handle negative indices [-4:-1]", function()
        -- En Python, pour dim=10, [-4:-1] équivaut à [6:9]
        local slice = { start = -4, stop = -1 }::types.Slices
        local length = Utils.computeLenghtFromSlice(DIM, slice)
        expect(length).toBe(3)
        expect(slice.start).toBe(6)
        expect(slice.stop).toBe(9)
    end)

    it("should reverse iteration with a negative step [::-1]", function()
        local slice = { step = -1 }::types.Slices
        local length = Utils.computeLenghtFromSlice(DIM, slice)
        expect(length).toBe(10)
        expect(slice.start).toBe(9)
        expect(slice.stop).toBe(-1)
    end)

    it("should correctly compute [7:2:-1]", function()
        local length = Utils.computeLenghtFromSlice(DIM, { start = 7, stop = 2, step = -1 })
        expect(length).toBe(5) -- Indices 7, 6, 5, 4, 3
    end)

    it("should return 0 for an empty or invalid slice [5:2] (positive step)", function()
        local length = Utils.computeLenghtFromSlice(DIM, { start = 5, stop = 2, step = 1 })
        expect(length).toBe(0)
    end)

    it("should return 0 for an empty slice [2:5:-1] (negative step)", function()
        local length = Utils.computeLenghtFromSlice(DIM, { start = 2, stop = 5, step = -1 })
        expect(length).toBe(0)
    end)

    it("should clamp out-of-bounds values on the right", function()
        local slice = { start = 5, stop = 100 }::types.Slices
        local length = Utils.computeLenghtFromSlice(DIM, slice)
        expect(length).toBe(5) 
        expect(slice.stop).toBe(10) 
    end)

    it("should clamp out-of-bounds values on the left (very negative indices)", function()
        local slice = { start = -100, stop = 5 }::types.Slices
        local length = Utils.computeLenghtFromSlice(DIM, slice)
        expect(length).toBe(5) 
        expect(slice.start).toBe(0)
    end)

end)
