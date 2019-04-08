import Foundation

protocol DataWriter : AbiTypeWriter {
}

public class DataWriterValue : DataWriter, Encodable {

    private let hexAsBytes: Data

    public init(hex: String) {
        self.hexAsBytes = DefaultHexWriter().hexToBytes(hex: hex)
    }

    func encode(writer: AbiEncodingContainer) throws {
        try writer.encode(UInt64.init(hexAsBytes.count), asDefault: true)
        try writer.encodeBytes(value: [UInt8](hexAsBytes))
    }
}
