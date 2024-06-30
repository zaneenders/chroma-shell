indirect enum _L3Node {
    case button(String, () -> Void)
    case group(GroupOrientation, [_L3Node])
    case style(L3Style)
    case switchTo(L3SwitchTo)
    case text(String)
    case selected(_L3Node)
    case textEntry(EntryStorage)
}

extension _L3Node {

    /// Flattens any groups with the same orientation. This removes the very
    /// nested nature of the tuples from the parsing.
    func _flattenSimilarGroups() -> _L3Node {
        switch self {
        case .textEntry, .button, .style, .switchTo, .text:
            return self
        case let .selected(node):
            let r = node._flattenSimilarGroups()
            return .selected(r)
        case let .group(orientation, children):
            return self._flattenGroup(orientation, children)
        }
    }

    /// Looks for nested groups and adopts there children.
    func _flattenGroup(_ orientation: GroupOrientation, _ children: [_L3Node])
        -> _L3Node
    {
        // This might be overkill for how many times I call flatten.
        var newChildren: [_L3Node] = []
        for child in children {
            let newChild = child._flattenSimilarGroups()
            switch newChild {
            case let .group(o, grandChildren):
                if o == orientation {
                    // Matching orientation, merge groups
                    newChildren += grandChildren.map {
                        $0._flattenSimilarGroups()
                    }
                } else {
                    newChildren.append(child._flattenGroup(o, grandChildren))
                }
            default:
                newChildren.append(child)
            }
        }
        return .group(orientation, newChildren)
    }

    /// Wraps the outer group in either a .vertical or .horizontal L3Group to
    /// trick the render into filling the screen and consuming the available
    /// area.
    func _wrapWithGroup() -> _L3Node {
        switch self {
        case .button, .switchTo, .text, .textEntry:
            return self
        case let .group(orientation, children):
            switch orientation {
            case .horizontal:
                return .group(.vertical, children)
            case .vertical:
                return .group(.horizontal, children)
            }
        case .selected, .style:
            fatalError("Not added yet")
        }
    }

    func createPath() -> SelectedStateNode {
        _getPath().0
    }

    /// Bool represents the path contains `.selected`
    private func _getPath() -> (SelectedStateNode, Bool) {
        switch self {
        case let .textEntry(s):
            return (.textEntry(s), false)
        case let .button(label, action):
            return (.button(label, action), false)
        case let .text(text):
            return (.text(text), false)
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
