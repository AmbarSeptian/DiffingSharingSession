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

    func testExample() {
         let old = [
            Alphabet(id: "0", char: "Alpha"),
            Alphabet(id: "1", char: "Beta"),
            Alphabet(id: "2", char: "Charlie"),
            Alphabet(id: "3", char: "Delta"),
         ]
        let new = [
            Alphabet(id: "3", char: "Delta"),
            Alphabet(id: "2", char: "Chocolate"), // updates
            Alphabet(id: "1", char: "Beta"),
            Alphabet(id: "5", char: "Echo"),
            Alphabet(id: "6", char: "Foxfort")
         ]
     
         let diff = old.diff(new)
        
         XCTAssertEqual(diff.updates, [1])
         XCTAssertEqual(diff.insertions, [3, 4])
         XCTAssertEqual(diff.deletions, [0])
         let expectedMoves = [(3, 0), (1,2)]
         for (index, move) in diff.moves.enumerated() {
             XCTAssertEqual(move.0, expectedMoves[index].0)
             XCTAssertEqual(move.1, expectedMoves[index].1)
         }
     }
}


struct Alphabet {
    let id: String
    let char: String
}

extension Alphabet: Diffable {
    var primaryKeyValue: String {
        return id
    }
}
