import Foundation
import UIKit
import CoreLocation
import MustacheServices

import RxSwift
import RxSwiftExt
import RxCocoa

public protocol RxGeoLocationServiceType {

    var authorized: Observable<Bool>! { get }

    var status: Observable<CLAuthorizationStatus>! { get }

    var location: Observable<CLLocation> { get }

}

public class RxGeoLocationService: RxGeoLocationServiceType {

    public var authorized: Observable<Bool>!

    public var status: Observable<CLAuthorizationStatus>!

    public lazy var location: Observable<CLLocation> = {
        return locationManager.rx.didUpdateLocations
                .filter({ (locations: [CLLocation]) -> Bool in
                    return locations.count > 0
                })
                .map({ (locations: [CLLocation]) -> CLLocation in
                    return locations.first!
                })
                .share(replay: 1)
                .do(onSubscribe: { [weak self] in
                    guard let self = self else { return }
                    self.locationManager.startUpdatingLocation()
                }, onDispose: { [weak self] in
                    guard let self = self else { return }
                    self.locationManager.stopUpdatingLocation()
                })
    }()

    fileprivate let disposeBag = DisposeBag()

    fileprivate let locationManager = CLLocationManager()

    public init() {

        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        self.authorized = self.locationManager.rx.didChangeAuthorizationStatus.startWith(self.locationManager.authorizationStatus).map( { [weak self] (status: CLAuthorizationStatus) -> Bool in
            switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    guard let self = self else { return true }
                    self.locationManager.startUpdatingLocation()
                    return true
                default:
                    return false
            }
        })

        self.status = self.locationManager.rx.didChangeAuthorizationStatus.startWith(self.locationManager.authorizationStatus)

    }
}
