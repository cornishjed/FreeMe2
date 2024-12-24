//
//  LocationManager.swift
//  FreeMe2
//
//  Created by Jed Powell on 21/03/2022.
//

import Foundation
import SwiftLocation
import CoreLocation

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var coordinates = Coordinates()
    var settings = Settings()

    func getCoordinatesFromPostcode(postcode: String) {
        var service = Geocoder.Apple(address: postcode)
        
        if postcode == "" {
            service = Geocoder.Apple(address: "SW1A 1AA")// default = Buckingham Palace
        }
        
        var location: String = ""
        var locationArr: [String] = [""]
        var longitude: [String] = [""]
        var latitude: [String] = [""]
        
        SwiftLocation.geocodeWith(service).then { result in
            // You will get an array of suggested [GeoLocation] objects with data and coordinates
            location = result.data?.description ?? ""
            if location != "" {
                locationArr = location.components(separatedBy: ",")
                latitude[0] = locationArr[0]
                longitude[0] = locationArr[1]
                
                latitude = latitude[0].components(separatedBy: ":")
                longitude = longitude[0].components(separatedBy: ":")
                
                self.coordinates.latitude = latitude[1]
                self.coordinates.longitude = longitude[1]
            }
        }
    }
    
    // if GPS not enabled
    
    func getDistanceBetweenCoordinates(postcode: String, activityLatitude: Double, activityLongitude: Double) -> Int {

        getCoordinatesFromPostcode(postcode: postcode)
        var miles = -1
        
        if let lat1 = Double(self.coordinates.latitude),  let lon1 = Double(self.coordinates.longitude) {
            let location1 = CLLocation(latitude: lat1, longitude: lon1)
            let location2 = CLLocation(latitude: activityLatitude, longitude: activityLongitude)
            let distanceInMeters : CLLocationDistance = location1.distance(from: location2)
            miles = Int(distanceInMeters * 0.000621371) // convert to miles
            print("Distance betweenAB = \(miles)")
        }
        return miles
    }
    
    func getDistanceBetweenCoordinates(activityLatitude: Double, activityLongitude: Double) -> Int {
        // Handle location update
        let userCoordinates = settings.getUserCoordinates()
        
        if let lat1 = Double(userCoordinates.latitude),  let lon1 = Double(userCoordinates.longitude) {
            let userLocation = CLLocation(latitude: lat1, longitude: lon1)
            let activityLocation = CLLocation(latitude: activityLatitude, longitude: activityLongitude)
            let distanceInMeters = userLocation.distance(from: activityLocation)
            //print("Distance betweenAB = \(Int(distanceInMeters * 0.000621371))")
            return Int(distanceInMeters * 0.000621371) // convert to miles
        } else {
            print("Not valid coordinates")
        }
        return -1
    }
    
}
