//
//  RangeLineOffsetterTests.swift
//  
//
//  Created by George Philip Malayil on 15/09/23.
//

@testable import Markdown
import XCTest

class RangeLineOffsetterTests: XCTestCase {
    /// Verify that a link that spans multiple lines does not crash cmark and also returns a valid range
    func testAdjustLineNumbers() {
        let text = """
        This is a link to an article on a different domain [link
        to an article](https://www.host.com/article).
        """

        let expectedDump = """
        Document @1:1-2:46
        └─ Paragraph @1:1-2:46
           ├─ Text @1:1-1:52 "This is a link to an article on a different domain "
           ├─ Link @1:52-2:45 destination: "https://www.host.com/article"
           │  ├─ Text @1:53-1:57 "link"
           │  ├─ SoftBreak
           │  └─ Text @2:1-2:14 "to an article"
           └─ Text @2:45-2:46 "."
        """

        let document = Document(parsing: text, source: nil, options: [.parseBlockDirectives, .parseSymbolLinks])
        XCTAssertEqual(expectedDump, document.debugDescription(options: .printSourceLocations))

        var lineAdjuster = RangeLineOffsetter(offsetBy: 250)
        lineAdjuster.visit(document)
        let adjustedDump = """
        Document @251:1-252:46
        └─ Paragraph @251:1-252:46
           ├─ Text @251:1-251:52 "This is a link to an article on a different domain "
           ├─ Link @251:52-252:45 destination: "https://www.host.com/article"
           │  ├─ Text @251:53-251:57 "link"
           │  ├─ SoftBreak
           │  └─ Text @252:1-252:14 "to an article"
           └─ Text @252:45-252:46 "."
        """
        XCTAssertEqual(adjustedDump, document.debugDescription(options: .printSourceLocations))
    }
}

