struct Text: Block, BuiltinBlock {
    let text: String
    let type: BuiltinBlocks = .text
}

extension Text {
    init(_ text: String) {
        self.text = text
    }
}

extension String: Block {
    public var component: some Block {
        Text(self)
    }
}
