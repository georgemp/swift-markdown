//
//  RangeLineOffsetter.swift
//  
//
//  Created by George Philip Malayil on 15/09/23.
//

import Foundation

public struct RangeLineOffsetter: MarkupWalker {
    /// The line number of the first line in the line run that needs adjustment.
    public var offsetBy: Int

    mutating public func defaultVisit(_ markup: Markup) {
        /// This should only be used in the parser where ranges are guaranteed
        /// to be filled in from cmark.
        let adjustedRange = markup.range.map { range -> SourceRange in
            // Add back the offset to the column as if the indentation weren't stripped.
            let start = SourceLocation(line: range.lowerBound.line + offsetBy,
                                       column: range.lowerBound.column,
                                       source: range.lowerBound.source)
            let end = SourceLocation(line: range.upperBound.line + offsetBy,
                                     column: range.upperBound.column,
                                     source: range.upperBound.source)
            return start..<end
        }

        // Warning! Unsafe stuff!
        // Unsafe mutation of shared reference types.
        // This should only ever be called during parsing. -- from RangeAdjuster.swift
        // Since, we need to do this, call this only immediately after parsing
        // and before we do anything else with the Markup

        markup.raw.markup.header.parsedRange = adjustedRange

        for child in markup.children {
            child.accept(&self)
        }

        // End unsafe stuff.
    }
}

