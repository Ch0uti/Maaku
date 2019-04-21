//
//  Heading.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

/// Represents a markdown heading level.
public enum HeadingLevel: Int {

    /// Unknown heading level.
    case unknown

    /// H1.
    // swiftlint:disable identifier_name
    case h1 = 1

    /// H2.
    // swiftlint:disable identifier_name
    case h2 = 2

    /// H3.
    // swiftlint:disable identifier_name
    case h3 = 3

    /// H4.
    // swiftlint:disable identifier_name
    case h4 = 4

    /// H5.
    // swiftlint:disable identifier_name
    case h5 = 5

    /// H6.
    // swiftlint:disable identifier_name
    case h6 = 6

}

/// Represents a markdown heading.
public struct Heading: LeafBlock {

    /// The underlying cmark_node.
    public let node: CMNode

    /// The heading level.
    public let level: HeadingLevel

    /// The inline items.
    public let items: [Inline]

    /// Creates a Heading with the specified level.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - level: The level.
    /// - Returns:
    ///     The initialized Heading.
    public init(node: CMNode, level: HeadingLevel) {
        self.node = node
        self.level = level
        items = []
    }

    /// Creates a Heading with the specified level and items.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - level: The level.
    ///     - items: The inline items.
    /// - Returns:
    ///     The initialized Heading.
    public init(node: CMNode, level: HeadingLevel, items: [Inline]) {
        self.node = node
        self.level = level
        self.items = items
    }

    /// Creates an updated Heading with the specified items.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - items: The inline items.
    /// - Returns:
    ///     The updated Heading.
    public func with(node: CMNode, items: [Inline]) -> Heading {
        return Heading(node: node, level: level, items: items)
    }
}

public extension Heading {

    func attributedText(style: Style) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        var headingStyle = style
        headingStyle.fonts.current = style.font(forHeading: self)
        headingStyle.colors.current = style.color(forHeading: self)

        for item in items {
            attributed.append(item.attributedText(style: headingStyle))
        }

        return attributed
    }

}
