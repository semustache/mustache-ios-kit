
import Foundation
import CoreLocation
import CoreBluetooth
import AVFoundation
import UserNotifications
import MustacheFoundation

public protocol PermissionsServiceType {
    
    var isLocationAllowed: Bool { get }
    
    var isNotificationAllowed: Bool { get }
    
    var isCameraAllowed: Bool { get }
    
    var isBlueToothAllowed: Bool { get }
    
    func locationPermission() async throws -> Bool
    
    func notificationPermission() async throws -> Bool
    
    func cameraRecordPermission() async throws -> Bool
    
    func bluetoothPermission() async throws -> Bool
}

public class PermissionsService: NSObject, PermissionsServiceType {
    
    public var isLocationAllowed: Bool {
        var authorizationStatus: CLAuthorizationStatus!
        if #available(iOS 14.0, *) {
            authorizationStatus = self.locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        return (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) && CLLocationManager.locationServicesEnabled()
    }
    
    @UserDefault("isNotificationAllowed", defaultValue: false)
    public var isNotificationAllowed: Bool
    
    public var isCameraAllowed: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) != .authorized
    }
    
    public var isBlueToothAllowed: Bool {
        return CBCentralManager.authorization == .allowedAlways
    }
    
    private var locationContinuation: CheckedContinuation<Bool, Error>?
    private lazy var locationManager: CLLocationManager = { return CLLocationManager() }()
    
    private var peripheralContinuation: CheckedContinuation<Bool, Error>?
    private lazy var peripheralManager: CBPeripheralManager = { return CBPeripheralManager() }()
    
    public func locationPermission() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            self.locationManager.delegate = self
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    public func notificationPermission() async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        self.isNotificationAllowed = result
        return result
    }
    
    public func cameraRecordPermission() async throws -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    public func bluetoothPermission() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            peripheralContinuation = continuation
            self.peripheralManager.delegate = self
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension PermissionsService: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined, .restricted, .denied:
                self.locationContinuation?.resume(returning: false)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationContinuation?.resume(returning: true)
            @unknown default:
                self.locationContinuation?.resume(returning: false)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            self.locationContinuation?.resume(throwing: error)
        }
    }
    
}

extension PermissionsService: CBPeripheralManagerDelegate {
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state != .unknown else { return }
        switch CBCentralManager.authorization {
            case .notDetermined, .restricted, .denied:
                self.locationContinuation?.resume(returning: false)
            case .allowedAlways:
                self.locationContinuation?.resume(returning: true)
            @unknown default:
                self.locationContinuation?.resume(returning: false)
        }
    }
}
