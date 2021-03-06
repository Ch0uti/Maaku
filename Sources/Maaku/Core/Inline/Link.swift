//
//  Link.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

import Foundation

/// Represents a markdown link.
public struct Link: Inline {

    /// Used for matching links that don't strictly conform to common mark syntax.
    private static let regex = try? NSRegularExpression(pattern: "^\\[\\w+\\]\\(.+\\)$", options: [])

    /// The underlying cmark_node.
    public let node: CMNode

    /// The inline text.
    public let text: [Inline]

    /// The link destination.
    public let destination: String?

    /// The link title.
    public let title: String?

    /// Returns the destination as a URL.
    public var url: URL? {
        guard let destination = destination else {
            return nil
        }

        return URL(string: destination)
    }

    /// Creates a Link with the specified values.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - text: The inline text.
    ///     - destination: The link destination.
    ///     - title: The link title.
    /// - Returns:
    ///     The initialized Link.
    public init(node: CMNode, text: [Inline], destination: String?, title: String?) {
        self.node = node
        self.text = text
        self.destination = destination
        self.title = title
    }

    /// Creates a Link with the specified values.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - destination: The link destination.
    ///     - title: The link title.
    /// - Returns:
    ///     The initialized Link.
    public init(node: CMNode, destination: String?, title: String?) {
        self.init(node: node, text: [], destination: destination, title: title)
    }

    /// Creates a Link with the specified Text.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - text: The Text.
    /// - Returns:
    ///     The initialized Link if a matching link was found, nil otherwise.
    public init?(node: CMNode, text: Text) {
        guard let regex = Link.regex else {
            return nil
        }

        self.node = node
        title = nil

        let range = NSRange(location: 0, length: text.text.utf16.count)
        let matches = regex.matches(in: text.text, options: [], range: range)

        if matches.count > 0 {
            let parts = text.text.components(separatedBy: "](")

            if parts.count == 2 {
                var linkName = parts[0]
                linkName.removeFirst()
                var dest = parts[1]
                dest.removeLast()

                self.text = [Text(node: node, text: linkName)]
                destination = dest
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    /// Creates an updated Link with the specified inline text.
    ///
    /// - Parameters:
    ///     - node: The underlying cmark_node.
    ///     - text: The inline text.
    /// - Returns:
    ///     The updated Link.
    func with(node: CMNode, text: [Inline]) -> Link {
        return Link(node: node, text: text, destination: destination, title: title)
    }

}

public extension Link {

    func attributedText(style: Style) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        for item in text {
            attributed.append(item.attributedText(style: style))
        }

        if let url = self.url {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.fonts.current,
                .foregroundColor: style.colors.link,
                .link: url,
                .underlineColor: style.colors.linkUnderline
            ]
            attributed.addAttributes(attributes, range: NSRange(location: 0, length: attributed.string.utf16.count))
        }

        return attributed
    }

}
