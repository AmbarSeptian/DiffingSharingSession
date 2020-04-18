//
//  ViewController.swift
//  DiffingAlgorithm
//
//  Created by Ambar Septian on 11/04/20.
//  Copyright © 2020 Ambar Septian. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var data = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        let person = Person.createDummies(startIndex: 0, count: 2)
//        var newPerson = person
//        newPerson.insert(Person(name: String.char(10), id: 10), at: 1)
//        newPerson.insert(Person(name: String.char(11), id: 11), at: 1)
////        newPerson.remove(at: 1)
//        let old = [
//          Person(id: 0, name: "Eirik"),
//          Person(id: 1, name: "Markus"),
//          Person(id: 2, name: "Andreas"),
//        ]
//
//        let new = [
//            Person(id: 2, name: "Andreas"),
//            Person(id: 1, name: "Markus"),
//            Person(id: 0, name: "Eirik"),
//        ]
//
//        let diff = old.diff(new)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let source = ["a", "b", "c", "c", "c"]
        let sink = ["e", "b", "c", "d", "a"]
        data = source
//        let diff = source.diff(sink)
//        print(diff)
        
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .done, target: self, action: #selector(self.refresh))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func refresh() {
        let source = ["a", "b", "c", "c", "c"]
        let sink = ["e", "b", "c", "d", "a"]
        data = sink
        let diff = source.diffBatch(sink)
        tableView.performBatchUpdates({
            tableView.deleteRows(at: diff.deletions, with: .automatic)
            tableView.insertRows(at: diff.insertions, with: .automatic)
            tableView.reloadRows(at: diff.updates, with: .automatic)
            diff.moves.forEach { from, move in
                tableView.moveRow(at: from, to: move)
            }
            
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }


}


struct Person {
    let id: Int
    let name: String
    
    init(charIndex: Int, id: Int) {
        self.name = String.char(charIndex)
        self.id = id
    }
    
    init(id: Int,name: String) {
        self.name = name
        self.id = id
    }

    
    static func createDummies(startIndex: Int = 0, count: Int = 1) -> [Self] {
        (startIndex..<startIndex+count).map { index -> Person in
            return Person(charIndex: index, id: index)
        }
    }
}

extension Person: Diffable {
    var primaryKeyValue: String {
        return "\(id)"
    }
    
    
}

extension String {
    static func char(_ index: Int) -> String {
        return "a b c d e f g h i j k l m n o p q r s t u v w x y z".components(separatedBy: " ")[index]
    }
}

extension String: Diffable {
    public var primaryKeyValue: String {
        return self
    }
}

//        let person = Person.createDummies(startIndex: 0, count: 2)
//        let newPerson = Person.createDummies(startIndex: 2, count: 4)
//        let person = [Person(name: "A", id: 0), Person(name: "B", id: 1), Person(name: "C", id: 2)]
//        let newPerson = [Person(name: "C", id: 2), Person(name: "B", id: 1), Person(name: "A", id: 0)]
