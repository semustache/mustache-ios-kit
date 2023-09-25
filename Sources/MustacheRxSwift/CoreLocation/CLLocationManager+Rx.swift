import CoreLocation
import RxSwift
import RxCocoa

// swiftlint:disable identifier_name
public extension Reactive where Base: CLLocationManager {

    /**
    Reactive wrapper for `delegate`.

    For more information take a look at `DelegateProxyType` protocol documentation.
    */

    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }

    // MARK: Responding to Location Events

    /**
    Reactive wrapper for `proxyDelegate` message.
    */
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didUpdateLocations:)))
                .map { a in
                    return try castOrThrow([CLLocation].self, a[1])
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var didFailWithError: Observable<NSError> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
                .map { a in
                    return try castOrThrow(NSError.self, a[1])
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var didFinishDeferredUpdatesWithError: Observable<NSError?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didFinishDeferredUpdatesWithError:)))
                .map { a in
                    return try castOptionalOrThrow(NSError.self, a[1])
                }
    }

    // MARK: Pausing Location Updates

    /**
    Reactive wrapper for `delegate` message.
    */
    var didPauseLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManagerDidPauseLocationUpdates(_:)))
                .map { _ in
                    return ()
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var didResumeLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManagerDidResumeLocationUpdates(_:)))
                .map { _ in
                    return ()
                }
    }

    // MARK: Responding to Heading Events

    /**
    Reactive wrapper for `delegate` message.
    */
    var didUpdateHeading: Observable<CLHeading> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
                .map { a in
                    return try castOrThrow(CLHeading.self, a[1])
                }
    }

    // MARK: Responding to Region Events

    /**
    Reactive wrapper for `delegate` message.
    */
    var didEnterRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
                .map { a in
                    return try castOrThrow(CLRegion.self, a[1])
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var didExitRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
                .map { a in
                    return try castOrThrow(CLRegion.self, a[1])
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    @available(OSX 10.10, *)
    var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didDetermineState:for:)))
                .map { a in
                    let stateNumber = try castOrThrow(NSNumber.self, a[1])
                    let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
                    let region = try castOrThrow(CLRegion.self, a[2])
                    return (state: state, region: region)
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: NSError)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:monitoringDidFailFor:withError:)))
                .map { a in
                    let region = try castOptionalOrThrow(CLRegion.self, a[1])
                    let error = try castOrThrow(NSError.self, a[2])
                    return (region: region, error: error)
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var didStartMonitoringForRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didStartMonitoringFor:)))
                .map { a in
                    return try castOrThrow(CLRegion.self, a[1])
                }
    }

    // MARK: Responding to Ranging Events

    /**
    Reactive wrapper for `delegate` message.
    */
    var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didRange:satisfying:)))
                .map { a in
                    let beacons = try castOrThrow([CLBeacon].self, a[1])
                    let region = try castOrThrow(CLBeaconRegion.self, a[2])
                    return (beacons: beacons, region: region)
                }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: NSError)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                        .locationManager(_:didFailRangingFor:error:)))
                .map { a in
                    let region = try castOrThrow(CLBeaconRegion.self, a[1])
                    let error = try castOrThrow(NSError.self, a[2])
                    return (region: region, error: error)
                }
    }

    // MARK: Responding to Visit Events

    /**
    Reactive wrapper for `delegate` message.
    */
    @available(iOS 8.0, *)
    var didVisit: Observable<CLVisit> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
                .map { a in
                    return try castOrThrow(CLVisit.self, a[1])
                }
    }

    // MARK: Responding to Authorization Changes

    /**
    Reactive wrapper for `delegate` message.
    */
    var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
                .locationManagerDidChangeAuthorization(_:)))
                .map { a in
                    let manager = try castOrThrow(CLLocationManager.self, a[0])
                    let status = manager.authorizationStatus
                    return status
                }
    }

}
