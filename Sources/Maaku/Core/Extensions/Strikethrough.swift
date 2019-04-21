//
//  Strikethrough.swift
//  Maaku
//
//  Created by Kris Baker on 12/21/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

/// Represents a markdown strikethrough.
public struct Strikethrough: Inline {

    /// The underlying cmark_node.
    public let node: CMNode

    /// The inline items.
    public let items: [Inline]

    /// Creates a Strikethrough.
    ///
    /// - Parameter node: The underlying cmark_node.
    /// - Returns:
    ///     The initialized Strikethrough.
    public init(node: CMNode) {
        self.node = node
        items = []
    }

    /// Creates a Strikethrough with the specified items.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - items: The inline items.
    /// - Returns:
    ///     The initialized Strikethrough.
    public init(node: CMNode, items: [Inline]) {
        self.node = node
        self.items = items
    }
}

public extension Strikethrough {

    func attributedText(style: Style) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        var strikethroughStyle = style
        strikethroughStyle.hasStrikethrough = true

        for item in items {
            attributed.append(item.attributedText(style: strikethroughStyle))
        }

        return attributed
    }

}
