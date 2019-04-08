import Foundation

class AbiEncodingContainer : UnkeyedEncodingContainer {
    var count: Int = 0
    var codingPath: [CodingKey] = []

    private var buffer: Array<UInt8>
    private var index: Int = 0

    func toData() -> Data {
        return Data(bytes: buffer[0..<index])
    }

    private func ensureCapacity(_ capacity: Int) {
        if (buffer.count - index < capacity) {
            var temp = Array<UInt8>(repeating: 0, count: buffer.count * 2 + capacity)
            temp[0..<index] = buffer[0..<index]
            buffer = temp
        }
    }

    init(capacity: Int) {
        buffer = Array<UInt8>(repeating: 0, count: capacity)
    }

    func encodeNil() throws {
        fatalError("nil encoding is not supported")
    }

    func encode(_ value: Bool) throws {
        fatalError("Bool encoding is not supported")
    }

    func encode(_ value: String) throws {
        let bytes = [UInt8](value.utf8)
        try encode(UInt64.init(bytes.count), asDefault: true)
        try encodeBytes(value: bytes)
    }

    func encode(_ value: Double) throws {
        fatalError("Double encoding is not supported")
    }

    func encode(_ value: Float) throws {
        fatalError("Float encoding is not supported")
    }

    func encode(_ value: Int) throws {
        try encode(Int64.init(value))
    }

    func encode(_ value: Int8) throws {
        fatalError("Int8 encoding is not supported")
    }

    func encode(_ value: Int16) throws {
        ensureCapacity(2)
        buffer[index] = UInt8.init((0xFF & value))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 8))
        index = index + 1
    }

    func encodeShort(_ value: Int) throws {
        ensureCapacity(2)
        buffer[index] = UInt8.init((0xFF & value))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 8))
        index = index + 1
    }

    func encode(_ value: Int32) throws {
        ensureCapacity(4)
        buffer[index] = UInt8.init((0xFF & value))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 8))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 16))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 24))
        index = index + 1
    }

    func encode(_ value: Int64) throws {
        ensureCapacity(8)
        buffer[index] = UInt8.init((0xFF & value))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 8))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 16))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 24))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 32))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 40))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 48))
        index = index + 1
        buffer[index] = UInt8.init((0xFF & value >> 56))
        index = index + 1
    }

    func encode(_ value: UInt) throws {
        fatalError("UInt encoding is not supported")
    }

    func encode(_ value: UInt8) throws {
        ensureCapacity(1)
        buffer[index] = value
        index = index + 1
    }

    func encode(_ value: UInt16) throws {
        try encodeUnsignedInteger(value)
    }

    func encode(_ value: UInt32) throws {
        try encodeUnsignedInteger(value)
    }

    func encode(_ value: UInt64, asDefault: Bool) throws {
        try asDefault ? encodeUnsignedInteger(value) : encodeBytes(value: value.bytes)
    }

    private func encodeUnsignedInteger<T : UnsignedInteger> (_ value: T) throws {
        var copy: T = value
        repeat {
            var b: UInt8 = UInt8.init(copy & 0x7f)
            copy = copy >> 7
            b = UInt8.init(Int.init(b) | ((copy > 0) ? 1 : 0) << 7)
            try encode(b)
        } while (copy != 0)
    }

    func encode(_ value: NameWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: AccountNameWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: BlockNumWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: BlockPrefixWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: PublicKeyWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: AssetWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: ChainIdWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: DataWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: TimestampWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: StringCollectionWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: HexCollectionWriter) throws {
        try value.encode(writer: self)
    }

    func encode(_ value: AccountNameCollectionWriter) throws {
        try value.encode(writer: self)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        fatalError("Generic encoding not supported")
    }

    func encodeBytes(value: Array<UInt8>) throws {
        ensureCapacity(value.count)
        buffer[index..<index+value.count] = value[0..<value.count]
        index += value.count
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func superEncoder() -> Encoder {
        fatalError()
    }
}



extension UInt64 {
    var bytes: [UInt8] {
        return [UInt8(truncatingIfNeeded: self), UInt8(truncatingIfNeeded: self >> 8), UInt8(truncatingIfNeeded: self >> 16), UInt8(truncatingIfNeeded: self >> 24), UInt8(truncatingIfNeeded: self >> 32), UInt8(truncatingIfNeeded: self >> 40), UInt8(truncatingIfNeeded: self >> 48), UInt8(truncatingIfNeeded: self >> 56)]
    }
}
