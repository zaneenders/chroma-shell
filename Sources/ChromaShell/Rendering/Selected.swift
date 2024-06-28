extension SelectedStateNode: Equatable {
    static func == (lhs: SelectedStateNode, rhs: SelectedStateNode) -> Bool {
        switch (lhs, rhs) {
        case let (.button(l, _), .button(r, _)):
            return l == r  // this could be bad but really only using this for testing.
        case let (.text(tl), .text(tr)):
            return tl == tr
        case let (.selected(ln), .selected(rn)):
            return ln == rn
        case let (.textEntry(ls), .textEntry(rs)):
            return ls == rs
        case let (.group(lt, lo, lc), .group(rt, ro, rc)):
            let a = lt == rt
            let b = lo == ro
            let c = lc == rc
            return a && b && c
        default:
            return false
        }
    }
}

indirect enum SelectedStateNode {
    case button(String, () -> Void)
    case text(String)
    case textEntry(EntryStorage)
    case selected(SelectedStateNode)
    case group(GroupIndex, GroupOrientation, [SelectedStateNode])
}

extension GroupIndex: Equatable {}
enum GroupIndex {
    case entire
    case index(Int)
}

extension GroupIndex {
    var testDescription: String {
        switch self {
        case .entire:
            return ".entire"
        case let .index(i):
            return ".index(\(i))"
        }
    }
}

enum MoveInResponse {
    case normal
    case action
    case input
}

extension SelectedStateNode {
    var testDescription: String {
        switch self {
        case let .textEntry(s):
            return ".textEntry(\(s.testDescription))"
        case let .button(l, _):
            return ".button(\"\(l)\", {})"
        case let .text(t):
            return ".text(\"\(t)\")"
        case let .selected(node):
            return ".selected(\(node.testDescription))"
        case let .group(index, orientation, children):
            var group = ""
            for (i, child) in children.enumerated() {
                group += child.testDescription
                if i != children.count - 1 {
                    group += ","
                }
            }
            return
                ".group(\(index.testDescription),\(orientation.testDescription),[\(group)])"
        }
    }
}

extension L3Node {
    func getPath() -> SelectedStateNode {
        _getPath().0
    }
    /// Bool represents the path contains `.selected`
    private func _getPath() -> (SelectedStateNode, Bool) {
        switch self.kind {
        case .textEntry:
            let t = self as! L3Entry
            return (.textEntry(t.storage), false)
        case .button:
            let b = self as! L3Button
            return (.button(b.label, b.action), false)
        case .text:
            let t = self as! L3Text
            return (.text(t.text), false)
        case .group:
            let g = self as! L3Group
            let result = g.children.map { $0._getPath() }
            var index: Int? = nil
            for (i, r) in result.enumerated() {
                if r.1 {
                    index = i
                }
            }
            if let index {
                return (
                    .group(.index(index), g.orientation, result.map { $0.0 }),
                    true
                )
            } else {
                return (
                    .group(.entire, g.orientation, result.map { $0.0 }), false
                )
            }
        case .selected:
            let s = self as! L3Selected
            let r = s.selected._getPath()
            return (.selected(r.0), r.1 || true)
        case .style:
            fatalError("Node not here yet")
        case .switchTo:
            fatalError("Node not here yet")
        }
    }

    /// Applies the path to the provided tree. The tree is assumed to have the
    /// previous L3Selected node stripped from it from `removeSelected(_:)`
    func applyPath(_ path: SelectedStateNode) -> (
        any L3Node, SelectedStateNode
    ) {
        switch path {
        case .button, .text, .textEntry:
            return (self, path)  // Nothing really to do here.
        case let .group(index, o, children):
            // Programming Error if this fails
            let group = self as! L3Group
            switch index {
            case .entire:
                // Do we assume that caller marked as selected? What do I need to do?
                return (group, .group(.entire, o, children))
            case let .index(i):
                var groupCopy = group.children
                var nodes: [SelectedStateNode] = []
                for (ci, c) in children.enumerated() {
                    if ci == i {
                        let s = group.children[i]
                        let (n, p) = s.applyPath(c)
                        groupCopy[i] = n
                        nodes.append(p)
                    } else {
                        nodes.append(c)
                    }
                }
                return (group, .group(.index(i), o, nodes))
            }
        case let .selected(child):
            return (L3Selected(selected: self), .selected(child))
        }
    }
}
