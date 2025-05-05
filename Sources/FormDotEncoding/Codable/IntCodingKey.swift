struct IntCodingKey: CodingKey {
    init(intValue: Int) {
        self.rawIntValue = intValue
    }

    var rawIntValue: Int

    var intValue: Int? { rawIntValue }

    init?(stringValue: String) {
        guard let intValue = Int(stringValue) else { return nil }
        self.init(intValue: intValue)
    }
    
    var stringValue: String { rawIntValue.description }
}
