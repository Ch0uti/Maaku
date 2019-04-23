//
//  Emphasis.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

/// Represents a markdown emphasis.
public struct Emphasis: Inline {

    /// The underlying cmark_node.
    public let node: CMNode

    /// The inline items.
    public let items: [Inline]

    /// Creates a Emphasis.
    ///
    /// - Parameter node: The underlying cmark_node.
    /// - Returns:
    ///     The initialized Emphasis.
    public init(node: CMNode) {
        self.node = node
        items = []
    }

    /// Creates a Emphasis with the specified items.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - items: The inline items.
    /// - Returns:
    ///     The initialized Emphasis.
    public init(node: CMNode, items: [Inline]) {
        self.node = node
        self.items = items
    }
}

public extension Emphasis {

    func attributedText(style: Style) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        var emphasisStyle = style
        emphasisStyle.emphasis()

        for item in items {
            attributed.append(item.attributedText(style: emphasisStyle))
        }

        return attributed
    }

}
