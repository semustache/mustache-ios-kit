
import Foundation

extension StringProtocol {
    
    subscript(_ offset: Int) -> Element {
        self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: Range<Int>) -> SubSequence {
        self.prefix(range.lowerBound + range.count).suffix(range.count)
    }
    
    subscript(_ range: ClosedRange<Int>) -> SubSequence {
        self.prefix(range.lowerBound + range.count).suffix(range.count)
    }
    
    subscript(_ range: PartialRangeThrough<Int>)-> SubSequence {
        self.prefix(range.upperBound.advanced(by: 1))
    }
    
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence {
        self.prefix(range.upperBound)
    }
    
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence {
        self.suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty,
              let i = index(startIndex,
                            offsetBy: offset,
                            limitedBy: index(before: endIndex))
        else {
            return nil
        }
        return self[i]
    }
}
