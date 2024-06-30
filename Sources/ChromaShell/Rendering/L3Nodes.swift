enum L3NodeKind {
    case button
    case group
    case style
    case switchTo
    case text
    case selected
    case textEntry
}
struct L3Entry: L3Node {
    let kind: L3NodeKind = .textEntry
    let storage: EntryStorage
}
protocol L3Node {
    var kind: L3NodeKind { get }
}
struct L3Selected: L3Node {
    let kind: L3NodeKind = .selected
    let selected: any L3Node
}
struct L3Button: L3Node {
    let kind: L3NodeKind = .button
    let label: String
    let action: () -> Void
}
struct L3Group: L3Node {
    let kind: L3NodeKind = .group
    let orientation: GroupOrientation
    let children: [any L3Node]
}
struct L3Style: L3Node {
    let kind: L3NodeKind = .style
}
struct L3SwitchTo: L3Node {
    let kind: L3NodeKind = .switchTo
    let label: String
}
struct L3Text: L3Node {
    let kind: L3NodeKind = .text
    let text: String
}

extension L2Node {
    /// Walks the L2Node tree and flattens L2Groups and L2Arrays into L3Group
    func mergeArraysIntoGroups() -> any L3Node {
        switch self.kind {
        case .textEntry:
            let t = self as! L2Entry
            return L3Entry(storage: t.storage)
        case .array:
            let a = self as! L2Array
            let children = a.nodes.map { $0.mergeArraysIntoGroups() }
            return L3Group(orientation: a.orientation, children: children)
        case .button:
            let b = self as! L2Button
            return L3Button(label: b.label, action: b.action)
        case .group:
            let g = self as! L2Group
            return L3Group(
                orientation: g.orientation,
                children: [g.wrapping.mergeArraysIntoGroups()])
        case .style:
            fatalError("Style not added yet")
        case .switchTo:
            fatalError("Switch not added yet")
        case .text:
            let t = self as! L2Text
            return L3Text(text: t.text)
        }
    }
}

extension L3Node {
    /// Flattens any groups with the same orientation. This removes the very
    /// nested nature of the tuples from the parsing.
    func flattenSimilarGroups() -> any L3Node {
        switch self.kind {
        case .textEntry, .button, .style, .switchTo, .text:
            return self
        case .selected:
            let s = self as! L3Selected
            let r = s.selected.flattenSimilarGroups()
            return L3Selected(selected: r)
        case .group:
            let g = self as! L3Group
            return g.flattenGroup()
        }
    }
}

extension L3Group {

    /// Looks for nested groups and adopts there children.
    func flattenGroup() -> L3Group {
        // This might be overkill for how many times I call flatten.
        var newChildren: [L3Node] = []
        for child in self.children {
            let newChild = child.flattenSimilarGroups()
            if let subGroup = newChild as? L3Group {
                if subGroup.orientation == self.orientation {
                    // Matching orientation, merge groups
                    newChildren += subGroup.children.map {
                        $0.flattenSimilarGroups()
                    }
                } else {
                    newChildren.append(subGroup.flattenGroup())
                }
            } else {
                // not a subgroup
                newChildren.append(child)
            }
        }
        return L3Group(orientation: self.orientation, children: newChildren)
    }
}

extension L3Node {
    /// Wraps the outer group in either a .vertical or .horizontal L3Group to
    /// trick the render into filling the screen and consuming the available
    /// area.
    func wrapWithGroup() -> any L3Node {
        switch self.kind {
        case .button, .switchTo, .text, .textEntry:
            return self
        case .group:
            let g = self as! L3Group
            switch g.orientation {
            case .horizontal:
                return L3Group(orientation: .vertical, children: [g])
            case .vertical:
                return L3Group(orientation: .horizontal, children: [g])
            }
        case .selected, .style:
            fatalError("Not added yet")
        }
    }
}
