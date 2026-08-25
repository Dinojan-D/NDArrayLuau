local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Utils = require(ReplicatedStorage.Shared.NDarray.core.Utils)

local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

describe("Utils Integer Casting & Wrap-Around Oracle", function()
    
    -----------------------------------------------------------------------------------------------
    -- 1. Unsigned Integers (castU)
    -----------------------------------------------------------------------------------------------
    describe("Utils.castU()", function()
        it("should keep nominal in-bounds values intact (u8)", function()
            expect(Utils.castU(8, 0)).toBe(0)
            expect(Utils.castU(8, 127)).toBe(127)
            expect(Utils.castU(8, 255)).toBe(255)
        end)

        it("should wrap around on positive overflow (u8)", function()
            expect(Utils.castU(8, 256)).toBe(0)
            expect(Utils.castU(8, 257)).toBe(1)
            expect(Utils.castU(8, 512)).toBe(0)
        end)

        it("should wrap around on negative values / underflow (u8)", function()
            expect(Utils.castU(8, -1)).toBe(255)
            expect(Utils.castU(8, -2)).toBe(254)
            expect(Utils.castU(8, -256)).toBe(0)
        end)

        it("should truncate floating-point numbers towards zero", function()
            expect(Utils.castU(8, 42.9)).toBe(42)
            expect(Utils.castU(8, 0.1)).toBe(0)
        end)

        it("should handle special float values (NaN, Inf, -Inf)", function()
            expect(Utils.castU(8, 0 / 0)).toBe(0)          -- NaN
            expect(Utils.castU(8, math.huge)).toBe(255)     -- +Infinity -> Max u8
            expect(Utils.castU(8, -math.huge)).toBe(0)      -- -Infinity -> Min u8
        end)

        it("should scale properly for higher bit-widths (u16, u32)", function()
            expect(Utils.castU(16, 65536)).toBe(0)          -- 2^16 overflow
            expect(Utils.castU(16, -1)).toBe(65535)         -- Max u16
            expect(Utils.castU(32, 4294967296)).toBe(0)     -- 2^32 overflow
        end)
    end)

    -----------------------------------------------------------------------------------------------
    -- 2. Signed Integers (castI) - Complement à deux
    -----------------------------------------------------------------------------------------------
    describe("Utils.castI()", function()
        it("should keep nominal in-bounds values intact (i8: [-128, 127])", function()
            expect(Utils.castI(8, 0)).toBe(0)
            expect(Utils.castI(8, 127)).toBe(127)
            expect(Utils.castI(8, -128)).toBe(-128)
            expect(Utils.castI(8, -1)).toBe(-1)
        end)

        it("should wrap around on positive overflow (i8)", function()
            expect(Utils.castI(8, 128)).toBe(-128)          -- Max + 1 -> Min
            expect(Utils.castI(8, 129)).toBe(-127)
            expect(Utils.castI(8, 255)).toBe(-1)
            expect(Utils.castI(8, 256)).toBe(0)
        end)

        it("should wrap around on negative underflow (i8)", function()
            expect(Utils.castI(8, -129)).toBe(127)         -- Min - 1 -> Max
            expect(Utils.castI(8, -130)).toBe(126)
        end)

        it("should truncate floating-point numbers towards zero", function()
            expect(Utils.castI(8, 10.8)).toBe(10)
            expect(Utils.castI(8, -10.8)).toBe(-10)
        end)

        it("should handle special float values (NaN, Inf, -Inf)", function()
            expect(Utils.castI(8, 0 / 0)).toBe(0)          -- NaN
            expect(Utils.castI(8, math.huge)).toBe(-1)      -- +Infinity
            expect(Utils.castI(8, -math.huge)).toBe(0)      -- -Infinity
        end)

        it("should scale properly for higher bit-widths (i16, i32)", function()
            expect(Utils.castI(16, 32768)).toBe(-32768)     -- 2^15 overflow (i16)
            expect(Utils.castI(16, -32769)).toBe(32767)     -- i16 underflow
        end)
    end)
end)