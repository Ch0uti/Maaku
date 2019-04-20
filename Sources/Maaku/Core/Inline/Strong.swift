//
//  Strong.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

/// Represents a markdown strong.
public struct Strong: Inline {

    /// The underlying cmark_node.
    public let node: CMNode
    
    /// The inline items.
    public let items: [Inline]

    /// Creates a Strong.
    ///
    /// - Parameter node: The underlying cmark_node.
    /// - Returns:
    ///     The initialized Strong.
    public init(node: CMNode) {
        self.node = node
        items = []
    }

    /// Creates a Strong with the specified items.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - items: The inline items.
    /// - Returns:
    ///     The initialized Strong.
    public init(node: CMNode, items: [Inline]) {
        self.node = node
        self.items = items
    }

}

public extension Strong {

    public func attributedText(style: Style) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        var strongStyle = style
        strongStyle.strong()

        for item in items {
            attributed.append(item.attributedText(style: strongStyle))
        }

        return attributed
    }

}
