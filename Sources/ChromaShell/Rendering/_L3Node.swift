indirect enum _L3Node {
    case button(L3Button)
    case group(GroupOrientation, [_L3Node])
    case style(L3Style)
    case switchTo(L3SwitchTo)
    case text(L3Text)
    case selected(_L3Node)
    case textEntry(L3Entry)
}

extension _L3Node {

    func createPath() -> SelectedStateNode {
        _getPath().0
    }

    /// Bool represents the path contains `.selected`
    private func _getPath() -> (SelectedStateNode, Bool) {
        switch self {
        case let .textEntry(s):
            return (.textEntry(s.storage), false)
        case let .button(button):
            return (.button(button.label, button.action), false)
        case let .text(text):
            return (.text(text.text), false)
        case let .group(orientation, children):
            let result = children.map { $0._getPath() }
            var index: Int? = nil
            for (i, r) in result.enumerated() {
                if r.1 {
                    index = i
                }
            }
            if let index {
                return (
                    .group(.index(index), orientation, result.map { $0.0 }),
                    true
                )
            } else {
                return (
                    .group(.entire, orientation, result.map { $0.0 }), false
                )
            }
        case let .selected(node):
            let r = node._getPath()
            return (.selected(r.0), r.1 || true)
        case .style:
            fatalError("Node not here yet")
        case .switchTo:
            fatalError("Node not here yet")
        }
    }
}
