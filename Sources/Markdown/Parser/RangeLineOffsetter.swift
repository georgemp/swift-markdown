//
//  RangeLineOffsetter.swift
//  
//
//  Created by George Philip Malayil on 15/09/23.
//

import Foundation

/*
 Rules of operation:
 1. If a child of the root document is offset, then the document's range should also be updated.
 2. If any child node is offsetted, then the range of the child needs to be updated.
 3. Range of a element is offset only if it's lowerBound >= startOffsetFromLine
 */

public struct RangeLineOffsetter: MarkupWalker {
    // Offset range of markup only if it's range is greater than or equal to startOffsetFromLine
    public var startOffsetFromLine: Int
    // Number of children to skip before offsetting range
    public var skipToChildIndex: Int?
    /// The number of lines to offset each line by.
    public var offsetBy: Int

    public init(offsetBy: Int, startOffsetFromLine: Int = 1, skipToChildIndex: Int? = nil) {
        self.offsetBy = offsetBy
        self.skipToChildIndex = skipToChildIndex
        self.startOffsetFromLine = startOffsetFromLine
    }

    mutating public func defaultVisit(_ markup: Markup) {
        /// This should only be used in the parser where ranges are guaranteed
        /// to be filled in from cmark.

        let adjustedRange = markup.range.map { range -> SourceRange in
            let start = startOffsetFromLine <= range.lowerBound.line ? SourceLocation(line: range.lowerBound.line + offsetBy, column: range.lowerBound.column, source: range.lowerBound.source) : range.lowerBound
            let end = startOffsetFromLine <= range.upperBound.line ? SourceLocation(line: range.upperBound.line + offsetBy, column: range.upperBound.column, source: range.upperBound.source) : range.upperBound

            return start..<end
        }

        var childrenToVisit = [Markup]()
        if adjustedRange != markup.range {
            // Warning! Unsafe stuff!
            // Unsafe mutation of shared reference types.
            // This should only ever be called during parsing. -- from RangeAdjuster.swift
            // Since, we need to do this, call this only immediately after parsing
            // and before we do anything else with the Markup
            markup.raw.markup.header.parsedRange = adjustedRange

            if let skipToChildIndex = skipToChildIndex {
                childrenToVisit.append(contentsOf: markup.children.dropFirst(skipToChildIndex))
            } else {
                childrenToVisit.append(contentsOf: markup.children)
            }
        }

        // We've updated the source range at root and skipped `skipToChildIndex` children. From, this point all the children need to be updated. So, we reset `skipToChildIndex` to 0.
        skipToChildIndex = nil
        for child in childrenToVisit {
            child.accept(&self)
        }
        // End unsafe stuff.
    }
}

