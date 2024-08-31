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

    func testSkipNodesAndAjustLineNumbers() {
        let text = """
        One
        *Two*

        **Three**
        Four

        Five

        Six
        Seven
        Eight
        """

        let expectedDump = """
        Document @1:1-11:6
        ├─ Paragraph @1:1-2:6
        │  ├─ Text @1:1-1:4 "One"
        │  ├─ SoftBreak
        │  └─ Emphasis @2:1-2:6
        │     └─ Text @2:2-2:5 "Two"
        ├─ Paragraph @4:1-5:5
        │  ├─ Strong @4:1-4:10
        │  │  └─ Text @4:3-4:8 "Three"
        │  ├─ SoftBreak
        │  └─ Text @5:1-5:5 "Four"
        ├─ Paragraph @7:1-7:5
        │  └─ Text @7:1-7:5 "Five"
        └─ Paragraph @9:1-11:6
           ├─ Text @9:1-9:4 "Six"
           ├─ SoftBreak
           ├─ Text @10:1-10:6 "Seven"
           ├─ SoftBreak
           └─ Text @11:1-11:6 "Eight"
        """

        let document = Document(parsing: text, source: nil, options: [.parseBlockDirectives, .parseSymbolLinks])
        XCTAssertEqual(expectedDump, document.debugDescription(options: .printSourceLocations))

        var lineAdjuster = RangeLineOffsetter(offsetBy: 2, startOffsetFromLine: 3, skipToChildIndex: 1)
        lineAdjuster.visit(document)
        let adjustedDump = """
        Document @1:1-13:6
        ├─ Paragraph @1:1-2:6
        │  ├─ Text @1:1-1:4 "One"
        │  ├─ SoftBreak
        │  └─ Emphasis @2:1-2:6
        │     └─ Text @2:2-2:5 "Two"
        ├─ Paragraph @6:1-7:5
        │  ├─ Strong @6:1-6:10
        │  │  └─ Text @6:3-6:8 "Three"
        │  ├─ SoftBreak
        │  └─ Text @7:1-7:5 "Four"
        ├─ Paragraph @9:1-9:5
        │  └─ Text @9:1-9:5 "Five"
        └─ Paragraph @11:1-13:6
           ├─ Text @11:1-11:4 "Six"
           ├─ SoftBreak
           ├─ Text @12:1-12:6 "Seven"
           ├─ SoftBreak
           └─ Text @13:1-13:6 "Eight"
        """
        XCTAssertEqual(adjustedDump, document.debugDescription(options: .printSourceLocations))
    }

    func testSkipLinesAndNodes() {
        let text = """
        One
        *Two*

        **Three**
        Four

        Five

        Six
        Seven
        Eight
        """

        let document = Document(parsing: text, source: nil, options: [.parseBlockDirectives, .parseSymbolLinks])
        var lineAdjuster = RangeLineOffsetter(offsetBy: 2, startOffsetFromLine: 5, skipToChildIndex: 1)
        lineAdjuster.visit(document)
        let adjustedDump = """
        Document @1:1-13:6
        ├─ Paragraph @1:1-2:6
        │  ├─ Text @1:1-1:4 "One"
        │  ├─ SoftBreak
        │  └─ Emphasis @2:1-2:6
        │     └─ Text @2:2-2:5 "Two"
        ├─ Paragraph @4:1-7:5
        │  ├─ Strong @4:1-4:10
        │  │  └─ Text @4:3-4:8 "Three"
        │  ├─ SoftBreak
        │  └─ Text @7:1-7:5 "Four"
        ├─ Paragraph @9:1-9:5
        │  └─ Text @9:1-9:5 "Five"
        └─ Paragraph @11:1-13:6
           ├─ Text @11:1-11:4 "Six"
           ├─ SoftBreak
           ├─ Text @12:1-12:6 "Seven"
           ├─ SoftBreak
           └─ Text @13:1-13:6 "Eight"
        """
        XCTAssertEqual(adjustedDump, document.debugDescription(options: .printSourceLocations))
    }
}

