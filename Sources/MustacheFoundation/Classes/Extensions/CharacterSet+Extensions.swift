
import Foundation

public extension CharacterSet {

    func contains(_ character: Character) -> Bool {
        let string = String(character)
        return string.rangeOfCharacter(from: self, options: [], range: string.startIndex..<string.endIndex) != nil
    }
}
