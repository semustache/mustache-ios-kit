import Foundation
import RxSwift
import AVFoundation

public extension Reactive where Base: AVCaptureDevice {
    
    static func requestAccess(for mediaType: AVMediaType) -> RxObservable<Bool> {
        return RxObservable<Bool>.create { observer in
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { result in
                observer.onNext(result)
            })
            return Disposables.create()
        }
    }
}
