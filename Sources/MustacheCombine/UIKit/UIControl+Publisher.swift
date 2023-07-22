import Combine
import UIKit

extension UIControl {
 
    public struct EventControlPublisher<Control: UIControl>: Publisher {
        public typealias Output = Control
        public typealias Failure = Never
        
        let control: Control
        let controlEvent: UIControl.Event
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = EventControlSubscription(control: control, event: controlEvent, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

public protocol Combinable {}

extension UIControl: Combinable {}

public extension Combinable where Self: UIControl {
    
    func publisher(for event: UIControl.Event) -> UIControl.EventControlPublisher<Self> {
        return UIControl.EventControlPublisher(control: self, controlEvent: event)
    }
    
}

