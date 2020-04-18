//
//  DiffingAlgorithmTests.swift
//  DiffingAlgorithmTests
//
//  Created by Ambar Septian on 15/04/20.
//  Copyright © 2020 Ambar Septian. All rights reserved.
//

import XCTest
@testable import DiffingAlgorithm

class DiffingAlgorithmTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() {
//        let source = ["a", "b", "c", "c", "c"]
//        let sink = ["e", "b", "c", "d", "a"]
//    
//        let diff = source.diff(sink)
//        XCTAssertEqual(diff.updates, [])
//        XCTAssertEqual(diff.insertions, [0, 3])
//        XCTAssertEqual(diff.deletions, [3, 4])
//        let expectedMoves = [(1, 1), (2,2), (0,4)]
//        for (index, move) in diff.moves.enumerated() {
//            XCTAssertEqual(move.0, expectedMoves[index].0)
//            XCTAssertEqual(move.1, expectedMoves[index].1)
//        }
//    }

   func testExample2() {
        let source = ["a", "b", "c"]
        let sink = ["e", "a", "b", "c", "c", "a"]
    
        let diff = source.diff(sink)
        XCTAssertEqual(diff.updates, [])
        XCTAssertEqual(diff.insertions, [0, 3])
        XCTAssertEqual(diff.deletions, [3, 4])
        let expectedMoves = [(1, 1), (2,2), (0,4)]
        for (index, move) in diff.moves.enumerated() {
            XCTAssertEqual(move.0, expectedMoves[index].0)
            XCTAssertEqual(move.1, expectedMoves[index].1)
        }
    }

}
