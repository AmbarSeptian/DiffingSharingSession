//
//  Array+Diff.swift
//  DiffingAlgorithm
//
//  Created by Ambar Septian on 11/04/20.
//  Copyright © 2020 Ambar Septian. All rights reserved.
//

import Foundation

extension Array where Element: Diffable {
    
    /// Calculate the changes between self and the `new` array.
    ///
    /// - Parameters:
    ///   - new: a collection to compare the calee to
    ///   - section: The section in which this diff should be applied to, this is used to create indexPath's. Default is 0
    /// - Returns: A tuple containing the changes.
    public func diffBatch(_ new: [Element], forSection section: Int = 0) -> (updates: [IndexPath], insertions: [IndexPath], deletions: [IndexPath], moves: [(IndexPath, IndexPath)]) {
        
        let diff = Diff()
        
        let result = diff.process(old: self, new: new)
        
        var deletions = [IndexPath]()
        var insertions = [IndexPath]()
        var updates = [IndexPath]()
        var moves = [(from: IndexPath, to: IndexPath)]()
        
        for step in result {
            switch step {
                
            case .delete(let index, _):
                deletions.append(IndexPath(row: index, section: section))
                
            case .insert(let index, _):
                insertions.append(IndexPath(row: index, section: section))
                
            case .update(let index, _):
                updates.append(IndexPath(row: index, section: section))
                
            case let .move(from, to, _):
                moves.append((from: IndexPath(row: from, section: section), to: IndexPath(row: to, section: section)))
                
            }
        }
        
        return (updates, insertions, deletions, moves)
        
    }
    
    public func diff(_ new: [Element]) -> (updates: [Int], insertions: [Int], deletions: [Int], moves: [(Int, Int)]) {
          
          let diff = Diff()
          
          let result = diff.process(old: self, new: new)
          
          var deletions = [Int]()
          var insertions = [Int]()
          var updates = [Int]()
          var moves = [(from: Int, to: Int)]()
          
          for step in result {
              switch step {
                  
              case .delete(let index, _):
                  deletions.append(index)
                  
              case .insert(let index, _):
                  insertions.append(index)
                  
              case .update(let index, _):
                  updates.append(index)
                  
              case let .move(from, to, _):
                  moves.append((from: from, to: to))
                  
              }
          }
          
          return (updates, insertions, deletions, moves)
          
      }
      
      
    
}
