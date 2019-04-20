//
//  Text.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

/// Represents markdown text.
public struct Text: Inline {

    /// The underlying cmark_node.
    public let node: CMNode

    /// The text.
    public let text: String

    /// Creates a Text with the specified text.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - text: The text.
    /// - Returns:
    ///     The initialized Text.
    public init(node: CMNode, text: String) {
        self.node = node
        self.text = text
    }

}

public extension Text {

    public func attributedText(style: Style) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: style.fonts.current,
            .foregroundColor: style.colors.current
        ]

        if style.hasStrikethrough {
            attributes[.strikethroughColor] = style.colors.current
            attributes[.strikethroughStyle] = NSNumber(value: NSUnderlineStyle.single.rawValue as Int)
        }

        return NSAttributedString(string: text, attributes: attributes)
    }

}
