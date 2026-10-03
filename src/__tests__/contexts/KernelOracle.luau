--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DType = require(ReplicatedStorage.Shared.NDarray.core.DType)
local types = require(ReplicatedStorage.Shared.NDarray.types)


local Oracle = {}


local writers: { [types.DtypeName]: (b: buffer, offset: number, value: number) -> () } = {
    i8 = buffer.writei8,
    u8 = buffer.writeu8,
    i16 = buffer.writei16,
    u16 = buffer.writeu16,
    i32 = buffer.writei32,
    u32 = buffer.writeu32,
    f32 = buffer.writef32,
    f64 = buffer.writef64,
}


function Oracle.fillBuffer(targetBuffer: buffer, dtype: types.DtypeName, value: number)
    local meta = DType.getDtypeMetadata(dtype)
    local writeFn = writers[dtype]
    
    local itemSize = meta.itemSize
    local bufferSize = buffer.len(targetBuffer)

    for pointer = 0, bufferSize - itemSize, itemSize do
        writeFn(targetBuffer, pointer, value)
    end
end


return Oracle