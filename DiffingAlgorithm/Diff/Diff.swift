/// Implementation of Paul Heckel's Diff Algorithm
///
/// > To compare two files, it is usually convenient to take a line as the
/// > basic unit, although other units are possible, such as word, sentence,
/// > paragraph, or character. We approach the problem by finding
/// similarities until only differences remain. We make two observations:
///
/// Preliminary Observations
///
/// 1. If a line occurs only once in each file, then it must be the same line,
/// although it may have been moved.
///
/// We use this observation to locate unaltered lines that we subsequently
/// exclude from further treatment.
///
/// 2. If a line has been found to be unaltered, and the lines immediately
/// adjacent to it in both files are identical, then these lines must be
/// the same line. This information can be used to find blocks of unchanged
/// lines.
///
/// References:
///
/// + https://gist.github.com/ndarville/3166060 (good breakdown)
/// + http://dl.acm.org/citation.cfm?id=359467 (paper)
///
/// Similar to:
///
/// + https://github.com/Instagram/IGListKit
class Diff {
    
    private var oldReferences = [Reference]()
    private var newReferences = [Reference]()
    
    /// A reference to an entry in the array, can either be a pointer (a change) or an index (unchanged)
    enum Reference {
        
        /// - pointer: A pointer to a symbol in the list of entries. This is used to identify changes.
        case pointer(Symbol)
        
        /// - index: An index reference. This is used to signify things which have not changed.
        case otherIndex(Int)
        
        /// A reference symbol.
        class Symbol {
            
            /// The count of the symbol in the old array
            var oldCount: Count = .zero
            
            /// The count of the symbol in the new array
            var newCount: Count = .zero
            
            /// The reference indexes in the old array
            var oldLineReferenceIndexes = [Int]()
            
            /// true if the symbol is available in both of the arrays
            var inBoth: Bool {
//                return !(oldCount == .zero || newCount == .zero)
                return (oldCount == newCount && oldCount != .zero)
            }
            
            var description: String {
                return """
                    oldCount: \(oldCount)
                    newCount: \(newCount)
                    oldLineReferenceIndexes: \(oldLineReferenceIndexes)
                    inBoth: \(inBoth)
                """
            }
            
        }
        
        var convertSymbol: Reference.Symbol? {
            if case .pointer(let asdf) = self {
                return asdf
            }
            return nil
        }
        
        /// An enum representing zero, one or many
        enum Count {
            
            /// - zero: equivalent to 0
            case zero
            
            /// - one: equivalent to 1
            case one
            
            /// - many: equivalent to anything larger than 1
            case many
            
            /// Advance to to the next value.
            ///
            /// zero -> one
            /// one -> many
            mutating func next() {
                
                switch self {
                    
                case .zero:
                    self = .one
                    
                case .one:
                    self = .many
                    
                case .many:
                    break
                    
                }
                
            }
        }
        
    }
   
    /// Process the old and new array to produce a list of diff steps.
    ///
    /// - Parameters:
    ///   - old: The array to compare.
    ///   - new: The array to compare against.
    /// - Returns: A list of DiffStep operations to perform on the old array to get the new array.
    func process<T: Diffable>(old: [T], new: [T]) -> [DiffStep<T>] {
        
         /// First pass
        newReferences = makeTableReferences(with: new, counter: { $0.newCount.next() })
        
        /// Second pass
        oldReferences = makeTableReferences(with: old, updateLineReference: true, counter: { $0.oldCount.next() })
        
        /// If a line occurs only once in each file, then it must be the same line, although it may have been moved.
        /// We use this observation to locate unaltered lines that we subsequently exclude from further treatment.
        
        /// Third pass
        findUniqueVirtualEntries()
        
        /// Final pass
        ///
        /// one entry for each index in the new array containing either:
        /// > a pointer to table[line]
        /// > the entry index in the old array

        return generateSteps(old: old, new: new)
    }
    
    /// Setup the context for the diffing operation
    ///
    /// This goes through the 5 passes of Paul Heckel's Diff Algorithm
    ///
    /// ## First Pass
    ///
    /// a. Each entry of array `new` is read in sequence
    /// b. An entry for each is created in the table, if it doesn't already exist
    /// c. `newCount` for the table entry is incremented
    /// d. `new[i]` is set to point to the table entry of index i
    ///
    /// ## Second Pass
    ///
    /// a. Each entry of array `old` is read in sequence
    /// b. An entry for each is created in the table, if it doesn't already exist
    /// c. `oldCount` for the table entry is incremented
    /// d. Add a reference index for the position of the entry in old
    /// e. `old[i]` is set to point to the table entry of index i
    ///
    /// ## Third Pass
    ///
    /// a. We use Observation 1:
    /// > If a entry occurs only once in each array, then it must be the same entry, although it may have been moved.
    /// > We use this observation to locate unaltered entries that we subsequently exclude from further treatment.
    ///
    /// b. Using this, we only process the entries where `oldCount` == `newCount` == 1.
    ///
    /// c. As the entries between `old` and `new` "must be the same entry, although it may have been moved", we alter the table pointers to the number of the entry in the other array.
    ///
    /// d. We also locate unique virtual entries
    ///  - immediately before the first and
    ///  - immediately after the last
    ///
    /// ## Fourth Pass
    ///
    /// a. We use Observation 2:
    /// > If a entry has been found to be unaltered, and the entries immediately adjacent to it in both arrays are identical, then these entries must be the same entry.
    /// > This information can be used to find blocks of unchanged entries.
    ///
    /// b. Using this, we process each entry in ascending order.
    ///
    /// c. If
    ///
    ///  - new[i] points to old[j], and
    ///  - new[i + 1] and old[j + 1] contain identical table entry pointers
    /// **then**
    ///  - old[j + 1] is set to entry i + 1, and
    ///  - old[i + 1] is set to entry j + 1
    ///
    /// ## Fifth Pass
    ///
    /// Similar to fourth pass, except:
    ///
    /// It processes each entry in descending order
    /// It uses j - 1 and i - 1 instead of j + 1 and i + 1
    ///
    /// - Parameters:
    ///   - old: The array to compare.
    ///   - new: The array to compare against.

    private var table: [String: Reference.Symbol] = [:]
    
    /// Generate table entries for the array, if updateLineReference is true the oldLineReferenceIndexes are also populated.
    ///
    /// First & Second pass
    ///
    /// - Parameters:
    ///   - array: The array calee to generate refernces for.
    ///   - updateLineReference: true if the oldLineReferenceIndexes should be updated
    ///   - counter: A function used to increase the counter for the reference symbol.
    /// - Returns: A list of symbol references for array `array`.
    private func makeTableReferences<T: Diffable>(with array: [T], updateLineReference: Bool = false, counter: (Reference.Symbol) -> Void) -> [Reference] {
       
        var entries = [Reference]()
        
        for (index, item) in array.enumerated() {
            
            let entry = table[item.primaryKeyValue] ?? Reference.Symbol()
            
            table[item.primaryKeyValue] = entry
            
            counter(entry)
            
            if updateLineReference {
                entry.oldLineReferenceIndexes.append(index)
            }
            
            entries.append(.pointer(entry))
        }
        
        return entries
        
    }
    
    /// Third pass
    private func findUniqueVirtualEntries() {
        
        for (index, item) in newReferences.enumerated() {
            
            if case .pointer(let entry) = item, entry.inBoth {
                
                guard entry.oldLineReferenceIndexes.count > 0 else {
                    continue
                }
                
                let oldIndex = entry.oldLineReferenceIndexes.removeFirst()
                
                newReferences[index]    = .otherIndex(oldIndex)
                oldReferences[oldIndex] = .otherIndex(index)
                
            }
            
        }
        
    }


    private func generateSteps<T>(old: [T], new:[T]) -> [DiffStep<T>] {
        var steps = [DiffStep<T>]()
        
        var deleteOffsets = Array(repeating: 0, count: old.count)
        var offset = 0
        
        for (index, item) in oldReferences.enumerated() {
            
            deleteOffsets[index] = offset
            
            if case .pointer(_) = item {
                steps.append(.delete(index: index, value: old[index]))
                offset += 1
            }
        }
        
        offset = 0
        
        for (index, item) in newReferences.enumerated() {
            
            switch item {
                
            case .pointer(_):
                
                steps.append(.insert(index: index, value: new[index]))
                offset += 1
                
            case .otherIndex(let otherIndex):
                
                if old[otherIndex] != new[index] {
                    steps.append(.update(index: index, value: new[index]))
                }
                
                let deleteOffset = deleteOffsets[otherIndex]
                
                if (otherIndex - deleteOffset + offset) != index {
                    steps.append(.move(from: otherIndex, to: index, value: new[index]))
                }
                
            }
        }
        
        return steps
    }
}

/// A description of a step to apply to an array to be able to transform one into the other.
enum DiffStep<T: Diffable>: CustomDebugStringConvertible {
    
    /// - insert: A insertation step.
    case insert(index: Int, value: T)
    
    /// - delete: A deletion step.
    case delete(index: Int, value: T)
    
    /// - move: A move step.
    case move(from: Int, to: Int, value: T)
    
    /// update: A update step.
    case update(index: Int, value: T)
    
    /// A debug string describing the diff step.
    public var debugDescription: String {
        switch self {
            
        case .insert(let idx, let value):
            return "+\(idx)@\(value)"
            
        case .delete(let idx, let value):
            return "-\(idx)@\(value)"
            
        case .move(from: let from, to: let to, value: let value):
            return "\(from)>\(to)@\(value)"
            
        case .update(index: let idx, value: let value):
            return "!\(idx)@\(value)"
            
        }
    }
    
}
