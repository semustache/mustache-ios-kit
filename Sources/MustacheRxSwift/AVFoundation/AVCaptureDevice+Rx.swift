import Foundation
import RxSwift
import AVFoundation

public extension Reactive where Base: AVCaptureDevice {
    
    static func requestAccess(for mediaType: AVMediaType) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { result in
                observer.onNext(result)
            })
            return Disposables.create()
        }
    }
}
