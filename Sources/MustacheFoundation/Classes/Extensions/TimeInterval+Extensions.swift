
import Foundation

public extension TimeInterval {
    
    static var minute: Double { 60 }
    
    static var hour: Double { .minute * 60 }
    
    static var day: Double { .hour * 24 }
    
    static var week: Double { .day * 7 }
    
}
