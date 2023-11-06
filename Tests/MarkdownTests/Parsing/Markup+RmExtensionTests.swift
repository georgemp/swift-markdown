//
//  Markup+RmExtensionTests.swift
//  
//
//  Created by George Philip Malayil on 21/09/23.
//

import XCTest
@testable import Markdown

final class Markup_RmExtensionTests: XCTestCase {

    func testSetRange() throws {
        let text = """
        Here in lies some markdown

        *to be, or, not to be* - **william shakespeare**
        """

        let document = Document(parsing: text)
        let source = document.range!.lowerBound.source
        print(document.debugDescription(options: .printSourceLocations))
        XCTAssertEqual(document.range, SourceLocation(line: 1, column: 1, source: source)..<SourceLocation(line: 3, column: 49, source: source))
        let adjustedRange = document.range.map {
            range -> SourceRange in
            let lowerBound = range.lowerBound
            let upperBound = SourceLocation(line: range.upperBound.line, column: 2, source: range.upperBound.source)

            return lowerBound..<upperBound
        }

        document.set(range: adjustedRange!)
        XCTAssertEqual(document.range, SourceLocation(line: 1, column: 1, source: source)..<SourceLocation(line: 3, column: 2, source: source))
     }
}
