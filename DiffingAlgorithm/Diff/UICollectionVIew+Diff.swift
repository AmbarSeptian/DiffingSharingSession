//
//  UICollectionVIew+Doff.swift
//  DiffingAlgorithm
//
//  Created by Ambar Septian on 11/04/20.
//  Copyright © 2020 Ambar Septian. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func apply(updates: [IndexPath], deletions: [IndexPath], insertions: [IndexPath], moves: [(from: IndexPath, to: IndexPath)], completion: (() -> Void)?) {
        
        let group = DispatchGroup()
        
        group.enter()
        
        performBatchUpdates({
            
            self.deleteItems(at: deletions)
            self.insertItems(at: insertions)
            
            for move in moves {
                self.moveItem(at: move.from, to: move.to)
            }
            
        }, completion: { _ in
            group.leave()
        })
        
        group.enter()
        
        performBatchUpdates({
            self.reloadItems(at: updates)
        }, completion: { _ in
            group.leave()
        })
        
        group.notify(queue: .main, execute: {
            completion?()
        })
        
    }
    
}
