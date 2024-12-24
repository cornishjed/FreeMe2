//
//  Coordinates.swift
//  FreeMe2
//
//  Created by Jed Powell on 27/03/2022.
//
//  Build Coordinates struct from latitude and longitude

import Foundation

public struct Coordinates {
    var latitude: String
    var longitude: String
    
    init() {
         latitude = ""
         longitude = ""
    }
    
    init(latitudeIn: String, longitudeIn: String) {
        latitude = latitudeIn
        longitude = longitudeIn
    }
}
