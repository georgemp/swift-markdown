//
//  RangeLineOffsetter.swift
//  
//
//  Created by George Philip Malayil on 15/09/23.
//

import Foundation

public struct RangeLineOffsetter: MarkupWalker {
    // Offset start of range only if it is less than startLine
    public var startLine: Int
    // Number of children to skip before offsetting range
    public var skipToChildIndex: Int
    /// The number of lines to offset each line by.
    public var offsetBy: Int

    public init(offsetBy: Int, startLine: Int = 1, skipToChildIndex: Int = 0) {
        self.offsetBy = offsetBy
        self.skipToChildIndex = skipToChildIndex
        self.startLine = startLine
    }

    mutating public func defaultVisit(_ markup: Markup) {
        /// This should only be used in the parser where ranges are guaranteed
        /// to be filled in from cmark.

        let adjustedRange = markup.range.map { range -> SourceRange in
            // If skipToChildIndex == 0, then the startLocation will remain the same as the original root of the document.
            let start = startLine <= range.lowerBound.line ? SourceLocation(line: range.lowerBound.line + offsetBy, column: range.lowerBound.column, source: range.lowerBound.source) : range.lowerBound
            let end = range.upperBound.line >= startLine ? SourceLocation(line: range.upperBound.line + offsetBy, column: range.upperBound.column, source: range.upperBound.source) : range.upperBound

            return start..<end
        }

        // Warning! Unsafe stuff!
        // Unsafe mutation of shared reference types.
        // This should only ever be called during parsing. -- from RangeAdjuster.swift
        // Since, we need to do this, call this only immediately after parsing
        // and before we do anything else with the Markup
        markup.raw.markup.header.parsedRange = adjustedRange

        let children = markup.children.dropFirst(skipToChildIndex)

        // We've updated the source range at root and skipped `skipToChildIndex` children. From, this point all the children need to be updated. So, we reset `skipToChildIndex` to 0.
        skipToChildIndex = 0
        for child in children {
            child.accept(&self)
        }

        // End unsafe stuff.
    }
}

