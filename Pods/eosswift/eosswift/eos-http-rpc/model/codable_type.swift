import Foundation

extension Encodable {
    public func toHex() -> String {
        let abiEncoder = AbiEncoder(capacity: 512)
        try! abiEncoder.encode(encodable: self)
        print(abiEncoder.toData().hexEncodedString())
        return abiEncoder.toData().hexEncodedString()
    }

    public func toData() -> Data {
        let abiEncoder = AbiEncoder(capacity: 512)
        try! abiEncoder.encode(encodable: self)
        return abiEncoder.toData()
    }
}

public protocol JSONType: Codable {
    var jsonValue: Any? { get }
}

extension Int: JSONType {
    public var jsonValue: Any? { return self }
}
extension String: JSONType {
    public var jsonValue: Any? { return self }
}
extension Double: JSONType {
    public var jsonValue: Any? { return self }
}
extension Bool: JSONType {
    public var jsonValue: Any? { return self }
}

public struct AnyJSONType: JSONType {
    public let jsonValue: Any?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            jsonValue = intValue
        } else if let stringValue = try? container.decode(String.self) {
            jsonValue = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            jsonValue = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode(Array<AnyJSONType>.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode(Dictionary<String, AnyJSONType>.self) {
            jsonValue = doubleValue
        } else {
            jsonValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("encoding not supported")
    }
}
