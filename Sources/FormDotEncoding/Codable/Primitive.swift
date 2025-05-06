protocol Primitive: Sendable & LosslessStringConvertible & Codable {}

extension Bool: Primitive {}
extension Int8: Primitive {}
extension UInt8: Primitive {}
extension Int16: Primitive {}
extension UInt16: Primitive {}
extension Int32: Primitive {}
extension UInt32: Primitive {}
extension Int64: Primitive {}
extension UInt64: Primitive {}
extension Int: Primitive {}
extension UInt: Primitive {}
extension Float: Primitive {}
extension Double: Primitive {}
extension String: Primitive {}
