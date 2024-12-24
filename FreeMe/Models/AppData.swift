//
//  AppData.swift
//  FreeMe2
//
//  Created by Jed Powell on 03/03/2022.
//  p408

//  Holds app user data

import SwiftUI

public class AppData: ObservableObject {
    
    @Published private var isButtonEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isButtonEnabled, forKey: "isButtonEnabled")
        }
    }
    
    @Published private var dayOff: String {
        didSet {
            UserDefaults.standard.set(dayOff, forKey: "dayOff")
        }
    }
    
    @Published private var postcode: String {
        didSet {
            UserDefaults.standard.set(postcode, forKey: "postcode")
        }
    }
    
    @Published private var firstTime: Bool {
        didSet {
            UserDefaults.standard.set(firstTime, forKey: "firstTime")
        }
    }
    
    @Published private var useCurrentLocation: Bool {
        didSet {
            UserDefaults.standard.set(useCurrentLocation, forKey: "useCurrentLocation")
        }
    }
    
    @Published private var distance: Int {
        didSet {
            UserDefaults.standard.set(distance, forKey: "distance")
        }
    }
    
    @Published private var distanceBetween: Int {
        didSet {
            UserDefaults.standard.set(distanceBetween, forKey: "distanceBetween")
        }
    }
    
    @Published private var userLatitude: String {
        didSet {
            UserDefaults.standard.set(userLatitude, forKey: "userLatitude")
        }
    }
    
    @Published private var userLongitude: String {
        didSet {
            UserDefaults.standard.set(userLongitude, forKey: "userLongitude")
        }
    }
    
    @Published private var ratings: Dictionary<String, String> {
        didSet {
            UserDefaults.standard.set(ratings, forKey: "ratings")
        }
    }
    
    @Published private var addToCalendar: Bool {
        didSet {
            UserDefaults.standard.set(addToCalendar, forKey: "addToCalendar")
        }
    }
    
    init() {
        if let _ = UserDefaults.standard.object(forKey: "isButtonEnabled") as? Bool {
            self.isButtonEnabled = true
        } else {
            self.isButtonEnabled = false
        }
        
        if let date = UserDefaults.standard.object(forKey: "dayOff") as? String {
            self.dayOff = date
        } else {
            self.dayOff = ""
        }
        
        if let postcode = UserDefaults.standard.object(forKey: "postcode") as? String {
            self.postcode = postcode
        } else {
            self.postcode = ""
        }
        
        if let _ = UserDefaults.standard.object(forKey: "firstTimeLaunch") as? Bool {
            self.firstTime = true
        } else {
            self.firstTime = false
        }
        
        if let _ = UserDefaults.standard.object(forKey: "useCurrentLocation") as? Bool {
            self.useCurrentLocation = true
        } else {
            self.useCurrentLocation = false
        }
        
        if let distance = UserDefaults.standard.object(forKey: "distance") {
            self.distance = distance as! Int
        } else {
            self.distance = 0
        }
        
        if let distanceBetween = UserDefaults.standard.object(forKey: "distanceBetween") {
            self.distanceBetween = distanceBetween as! Int
        } else {
            self.distanceBetween = 0
        }
        
        if let userLatitude = UserDefaults.standard.object(forKey: "userLatitude") as? String {
            self.userLatitude = userLatitude
        } else {
            self.userLatitude = ""
        }
        
        if let userLongitude = UserDefaults.standard.object(forKey: "userLongitude") as? String {
            self.userLongitude = userLongitude
        } else {
            self.userLongitude = ""
        }
        
        if let ratings = UserDefaults.standard.object(forKey: "ratings") as? Dictionary<String, String> {
            self.ratings = ratings
        } else {
            self.ratings = ["": ""]
        }
        
        if let _ = UserDefaults.standard.object(forKey: "addToCalendar") as? Bool {
            self.addToCalendar = true
        } else {
            self.addToCalendar = false
        }
        
    }
    
}
