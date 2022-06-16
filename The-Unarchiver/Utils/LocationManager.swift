//
//  LocationManager.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/16.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    public static let shared = LocationManager()
    let locationManager = CLLocationManager()
    
    func startLocation() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation() {
        locationManager.stopUpdatingHeading()
    }
    
    func requestAuthority() {
        locationManager.requestAlwaysAuthorization()
    }

}


extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currLocation = locations.last {
            print(message: "定位成功，\(currLocation.coordinate.latitude) \(currLocation.coordinate.longitude) \(currLocation.altitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(message: "定位失败：\(error.localizedDescription)")
    }
}
