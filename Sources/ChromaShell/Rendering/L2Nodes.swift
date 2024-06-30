enum L2NodeKind {
    case array
    case button
    case group
    case style
    case switchTo
    case text
    case textEntry
}

protocol L2Node {
    var kind: L2NodeKind { get }
}
struct L2Entry: L2Node {
    let kind: L2NodeKind = .textEntry
    let storage: EntryStorage
}
struct L2Array: L2Node {
    let kind: L2NodeKind = .array
    let nodes: [any L2Node]
    let orientation: GroupOrientation
}
struct L2Button: L2Node {
    let kind: L2NodeKind = .button
    let label: String
    let action: () -> Void
}
struct L2Group: L2Node {
    let kind: L2NodeKind = .group
    let orientation: GroupOrientation
    let wrapping: any L2Node
}
struct L2Style: L2Node {
    let kind: L2NodeKind = .style
}
struct L2SwitchTo: L2Node {
    let kind: L2NodeKind = .switchTo
}
struct L2Text: L2Node {
    let kind: L2NodeKind = .text
    let text: String
}

extension L2Node {

    func _mergeArraysIntoGroups() -> L3Node {
        switch self.kind {
        case .textEntry:
            let t = self as! L2Entry
            return .textEntry(t.storage)
        case .array:
            let a = self as! L2Array
            let children = a.nodes.map { $0._mergeArraysIntoGroups() }
            return .group(a.orientation, children)
        case .button:
            let b = self as! L2Button
            return .button(b.label, b.action)
        case .group:
            let g = self as! L2Group
            return .group(g.orientation, [g.wrapping._mergeArraysIntoGroups()])
        case .style:
            fatalError("Style not added yet")
        case .switchTo:
            fatalError("Switch not added yet")
        case .text:
            let t = self as! L2Text
            return .text(t.text)
        }
    }
}
