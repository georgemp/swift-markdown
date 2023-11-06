//
//  Markup+RmExtensions.swift
//  
//
//  Created by George Philip Malayil on 21/09/23.
//

import Foundation

public extension Markup {
    // Warning! Unsafe stuff!
    // Unsafe mutation of shared reference types.
    // This should only ever be called during parsing. -- from RangeAdjuster.swift
    // Use with extreme caution.
    func set(range: SourceRange) {
        self.raw.markup.header.parsedRange = range
    }
}
