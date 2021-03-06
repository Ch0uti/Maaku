//
//  DocumentConverter.swift
//  Maaku
//
//  Created by Kris Baker on 12/20/17.
//  Copyright © 2017 Kristopher Baker. All rights reserved.
//

// swiftlint:disable file_length

/// Represents a way of converting a CMDocument to a Document
public class DocumentConverter {

    /// The converted block nodes.
    fileprivate var nodes: [Node] = []

    /// Creates a document converter.
    ///
    /// - Returns:
    ///     The initialized converter.
    public init() {
    }

    /// Converts the CMDocument to a Document.
    ///
    /// - Parameters:
    ///     - document: The CMDocument.
    /// - Throws:
    ///     `CMParseError.invalidEventType` if an invalid event type is encountered.
    /// - Returns:
    ///     The converted document.
    public func convert(document: CMDocument) throws -> Document {
        nodes = []
        let parser = CMParser(document: document, delegate: self)
        try parser.parse()

        var items = [Block]()

        for node in nodes {
            if let blockNode = node as? Block {
                items.append(blockNode)
            }
        }

        return Document(node: document.node, items: items)
    }

}

/// Extends DocumentConverter as a CMParserDelegate.
extension DocumentConverter: CMParserDelegate {

    public func parserDidStartDocument(node: CMNode, parser: CMParser) {

    }

    public func parserDidEndDocument(node: CMNode, parser: CMParser) {

    }

    public func parserDidAbort(parser: CMParser) {

    }

    public func parser(node: CMNode, parser: CMParser, foundText text: String) {
        if !text.isEmpty {
            nodes.append(Text(node: node, text: text))
        }
    }

    public func parserFoundThematicBreak(parser: CMParser) {
        nodes.append(HorizontalRule())
    }

    public func parser(node: CMNode, parser: CMParser, didStartHeadingWithLevel level: Int32) {
        nodes.append(Heading(node: node, level: HeadingLevel(rawValue: Int(level)) ?? .unknown))
    }

    public func parser(node: CMNode, parser: CMParser, didEndHeadingWithLevel level: Int32) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if let heading = nodes.last as? Heading {
            nodes.removeLast()
            nodes.append(heading.with(node: node, items: inlineItems))
        }
    }

    public func parserDidStartParagraph(node: CMNode, parser: CMParser) {
        let paragraph = Paragraph(node: node)
        nodes.append(paragraph)
    }

    public func parserDidEndParagraph(node: CMNode, parser: CMParser) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        var plugin: Plugin?

        if inlineItems.count == 1 {
            // check for plugins, which can either be a link node, or a text node
            var markdownLink: Link? = inlineItems.first as? Link

            if markdownLink == nil, let text = inlineItems.first as? Text {
                markdownLink = Link(node: node, text: text)
            }

            if let link = markdownLink, let name = link.text.first as? Text, let contents = link.destination {
                plugin = PluginManager.parseBlockLink(name: name.text, contents: contents)
            }
        }

        if nodes.last is Paragraph {
            nodes.removeLast()

            if let plug = plugin {
                nodes.append(plug)
            } else {
                nodes.append(Paragraph(node: node, items: inlineItems))
            }
        }
    }

    public func parserDidStartEmphasis(node: CMNode, parser: CMParser) {
        nodes.append(Emphasis(node: node))
    }

    public func parserDidEndEmphasis(node: CMNode, parser: CMParser) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline, !(item is Emphasis) {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is Emphasis {
            nodes.removeLast()
            nodes.append(Emphasis(node: node, items: inlineItems))
        }
    }

    public func parserDidStartStrong(node: CMNode, parser: CMParser) {
        nodes.append(Strong(node: node))
    }

    public func parserDidEndStrong(node: CMNode, parser: CMParser) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline, !(item is Strong) {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is Strong {
            nodes.removeLast()
            nodes.append(Strong(node: node, items: inlineItems))
        }
    }

    public func parser(node: CMNode, parser: CMParser, didStartLinkWithDestination destination: String?, title: String?) {
        let link = Link(node: node, destination: destination, title: title)
        nodes.append(link)
    }

    public func parser(node: CMNode, parser: CMParser, didEndLinkWithDestination destination: String?, title: String?) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline, !(item is Link) {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if let link = nodes.last as? Link {
            nodes.removeLast()
            nodes.append(link.with(node: node, text: inlineItems))
        }
    }

    public func parser(parser: CMParser, didStartImageWithDestination destination: String?, title: String?) {
        nodes.append(Image(destination: destination, title: title))
    }

    public func parser(parser: CMParser, didEndImageWithDestination destination: String?, title: String?) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline, !(item is Image) {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if let image = nodes.last as? Image {
            nodes.removeLast()
            nodes.append(image.with(description: inlineItems))
        }
    }

    public func parser(parser: CMParser, foundHtml html: String) {
        nodes.append(HtmlBlock(html: html))
    }

    public func parser(parser: CMParser, foundInlineHtml html: String) {
        // TODO: update DocumentConverter to properly deal with inline HTML
        nodes.append(InlineHtml(html: html))
    }

    public func parser(parser: CMParser, foundCodeBlock code: String, info: String) {
        nodes.append(CodeBlock(code: code, info: info))
    }

    public func parser(parser: CMParser, foundInlineCode code: String) {
        nodes.append(InlineCode(code: code))
    }

    public func parserFoundSoftBreak(parser: CMParser) {
        nodes.append(SoftBreak())
    }

    public func parserFoundLineBreak(parser: CMParser) {
        nodes.append(LineBreak())
    }

    public func parserDidStartBlockQuote(parser: CMParser) {
        nodes.append(BlockQuote())
    }

    public func parserDidEndBlockQuote(parser: CMParser) {
        var blockItems: [Block] = []

        while let item = nodes.last as? Block {
            if let quote = item as? BlockQuote, quote.items.count == 0 {
                break
            }

            blockItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is BlockQuote {
            nodes.removeLast()
            nodes.append(BlockQuote(items: blockItems))
        }
    }

    public func parser(parser: CMParser, didStartUnorderedListWithTightness tight: Bool) {
        nodes.append(UnorderedList())
    }

    public func parser(parser: CMParser, didEndUnorderedListWithTightness tight: Bool) {
        var blockItems: [Block] = []

        while let item = nodes.last as? Block, !(item is UnorderedList) {
            blockItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is UnorderedList {
            nodes.removeLast()
            nodes.append(UnorderedList(items: blockItems))
        }
    }

    public func parser(parser: CMParser, didStartOrderedListWithStartingNumber num: Int32, tight: Bool) {
        nodes.append(OrderedList())
    }

    public func parser(parser: CMParser, didEndOrderedListWithStartingNumber num: Int32, tight: Bool) {
        var blockItems: [Block] = []

        while let item = nodes.last as? Block, !(item is OrderedList) {
            blockItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is OrderedList {
            nodes.removeLast()
            nodes.append(OrderedList(items: blockItems))
        }
    }

    public func parserDidStartListItem(parser: CMParser) {
        nodes.append(ListItem())
    }

    public func parserDidEndListItem(parser: CMParser) {
        var blockItems: [Block] = []

        while let item = nodes.last as? Block, !(item is ListItem) {
            blockItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is ListItem {
            nodes.removeLast()
            nodes.append(ListItem(items: blockItems))
        }
    }

    public func parser(parser: CMParser, didStartCustomBlock content: String) {

    }

    public func parser(parser: CMParser, didEndCustomBlock content: String) {

    }

    public func parser(parser: CMParser, didStartCustomInline content: String) {

    }

    public func parser(parser: CMParser, didEndCustomInline content: String) {

    }

    public func parser(parser: CMParser, didStartFootnoteDefinition num: Int32) {
        nodes.append(FootnoteDefinition(number: Int(num)))
    }

    public func parser(parser: CMParser, didEndFootnoteDefinition num: Int32) {
        var blockItems: [Block] = []

        while let item = nodes.last as? Block, !(item is FootnoteDefinition) {
            blockItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is FootnoteDefinition {
            nodes.removeLast()
            nodes.append(FootnoteDefinition(number: Int(num), items: blockItems))
        }
    }

    public func parser(parser: CMParser, foundFootnoteReference reference: String) {
        nodes.append(FootnoteReference(reference: reference))
    }

    public func parser(parser: CMParser, didStartTableWithColumns columns: UInt16, alignments: [String]) {
        nodes.append(Table())
    }

    public func parser(parser: CMParser, didEndTableWithColumns columns: UInt16, alignments: [String]) {
        var rows: [TableRow] = []
        var header = TableHeader()

        while let item = nodes.last as? TableLine {
            if let tableHeader = item as? TableHeader {
                header = tableHeader
            } else if let row = item as? TableRow {
                rows.insert(row, at: 0)
            }

            nodes.removeLast()
        }

        if nodes.last is Table {
            nodes.removeLast()
            nodes.append(Table(header: header, rows: rows, columns: Int(columns), alignments: alignments))
        }
    }

    public func parserDidStartTableHeader(parser: CMParser) {
        nodes.append(TableHeader())
    }//TableLine

    public func parserDidEndTableHeader(parser: CMParser) {
        var cells: [TableCell] = []

        while let item = nodes.last as? TableCell {
            cells.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is TableHeader {
            nodes.removeLast()
            nodes.append(TableHeader(cells: cells))
        }
    }

    public func parserDidStartTableRow(parser: CMParser) {
        nodes.append(TableRow())
    }

    public func parserDidEndTableRow(parser: CMParser) {
        var cells: [TableCell] = []

        while let item = nodes.last as? TableCell {
            cells.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is TableRow {
            nodes.removeLast()
            nodes.append(TableRow(cells: cells))
        }
    }

    public func parserDidStartTableCell(parser: CMParser) {
        nodes.append(TableCell())
    }

    public func parserDidEndTableCell(parser: CMParser) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is TableCell {
            nodes.removeLast()
            nodes.append(TableCell(items: inlineItems))
        }
    }

    public func parserDidStartStrikethrough(node: CMNode, parser: CMParser) {
        nodes.append(Strikethrough(node: node))
    }

    public func parserDidEndStrikethrough(node: CMNode, parser: CMParser) {
        var inlineItems: [Inline] = []

        while let item = nodes.last as? Inline, !(item is Strikethrough) {
            inlineItems.insert(item, at: 0)
            nodes.removeLast()
        }

        if nodes.last is Strikethrough {
            nodes.removeLast()
            nodes.append(Strikethrough(node: node, items: inlineItems))
        }
    }

}
