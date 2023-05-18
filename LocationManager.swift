//
//  LocationManager.swift
//  SwiftUi+Weather
//
//  Created by Robert Covu on 5/16/23.
//

import Foundation
import CoreLocation
import Combine

enum LocationError: Error {
    case rejected
    case badData
    case invalid
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var city = "Mars"
    
    var locationSubject = PassthroughSubject<Void, LocationError>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocation()
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
        if locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print("location updated...")
        self.getPlace(for:location , completion: { [weak self]  placeMark in
            self!.city = (placeMark?.name)!
            self?.locationSubject.send()
        })
        print(#function, location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        self.locationSubject.send()
    }
}

// MARK: - Get Placemark
extension LocationManager {

    func getPlace(for location: CLLocation,
              completion: @escaping (CLPlacemark?) -> Void) {

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                completion(nil)
                return
            }
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            completion(placemark)
        }
    }
}
