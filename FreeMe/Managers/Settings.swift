//
//  SettingsManager.swift
//  FreeMe2
//
//  Created by Jed Powell on 25/03/2022.
//

import Foundation

class Settings: ObservableObject {
    
    func setLocationSetting(ls: Bool) {
        UserDefaults.standard.set(ls, forKey: "useCurrentLocation")
    }
    
    func setDayOff(d: Date) {
        UserDefaults.standard.set(d, forKey: "dayOff")
    }
    
    func setPostcode(p: String) {
        UserDefaults.standard.set(p, forKey: "postcode")
    }
    
    func setDistance(d: Double) {
        UserDefaults.standard.set(d, forKey: "distance")
    }
    
    func setDistanceBetween(db: Int) {
        UserDefaults.standard.set(db, forKey: "distanceBetween")
    }
    
    func setUserLatitude(la: String) {
        UserDefaults.standard.set(la, forKey: "userLatitude")
    }
    
    func setUserLongitude(lo: String) {
        UserDefaults.standard.set(lo, forKey: "userLongitude")
    }
    
    func setRatings(id: String, rating: Int) {
        var starRating = ""
        
        for _ in 0..<rating {
            starRating = starRating + "⭐️"
        }
        
        for _ in starRating.count..<5 {
            starRating = starRating + " "
        }
        
        var ratings = getRatings()
        ratings[id] = starRating
        UserDefaults.standard.set(ratings, forKey: "ratings")
    }
    
    func getLocationSetting() -> Bool {
        print("Location setting: \(UserDefaults.standard.bool(forKey: "useCurrentLocation"))")
        return UserDefaults.standard.bool(forKey: "useCurrentLocation")
    }
    
    func getDayOff() -> Date {
        let calendar = Calendar.current
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let dayOffString = UserDefaults.standard.object(forKey: "dayOff")
        
        let dayOffComponents = DateComponents(timeZone: TimeZone(abbreviation: "UTC+01:00"),
                                              year: calendar.component(.year, from: dayOffString as! Date),
                                              month: calendar.component(.month, from: dayOffString as! Date),
                                              day: calendar.component(.day, from: dayOffString as! Date),
                                              hour: calendar.component(.hour, from: dayOffString as! Date),
                                              minute: calendar.component(.minute, from: dayOffString as! Date))
        
        let dayOff = NSCalendar.current.date(from: dayOffComponents)
        
        return dayOff!
    }
    
    func getDayOfNotification() -> Date {
        let calendar = Calendar.current
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // need string format
        let dayOffString = UserDefaults.standard.object(forKey: "dayOff")
        
        var dayOffNotify = DateComponents(timeZone: TimeZone(abbreviation: "UTC+01:00"),
                                          year: calendar.component(.year, from: dayOffString as! Date),
                                          month: calendar.component(.month, from: dayOffString as! Date),
                                          day: calendar.component(.day, from: dayOffString as! Date) - 1,
                                          hour: calendar.component(.hour, from: dayOffString as! Date),
                                          minute: calendar.component(.minute, from: dayOffString as! Date) + 1)
        
        // Take care of month/year edge case
        
        let monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        
        if dayOffNotify.day! < 1 {
            dayOffNotify.day! = monthDays[dayOffNotify.month! - 1]
            dayOffNotify.month = dayOffNotify.month! - 1
            if dayOffNotify.month! < 1 {
                dayOffNotify.month = 12
            }
        }
        
        let dayOff = NSCalendar.current.date(from: dayOffNotify)
        
        return dayOff!
    }
    
    func getPostcode() -> String {
        return UserDefaults.standard.string(forKey: "postcode") ?? ""
    }
    
    func getDistance() -> Int {
        return UserDefaults.standard.integer(forKey: "distance")
    }
    
    func getDistanceBetween() -> Int {
        return UserDefaults.standard.integer(forKey: "distanceBetween")
    }
    
    func getUserCoordinates() -> Coordinates {
        // put together as never used seperate
        let userCoordinates = Coordinates(latitudeIn: UserDefaults.standard.string(forKey: "userLatitude") ?? "", longitudeIn: UserDefaults.standard.string(forKey: "userLongitude") ?? "")
        return userCoordinates
    }
    
    func getRatings() -> Dictionary<String, String> {
        let ratings: [String: String] = UserDefaults.standard.object(forKey: "ratings") as? [String: String] ?? [:]
        return ratings
    }
    
    func getRatingFromId(id: String) -> String {
        let ratings = getRatings()
        let keyExists = ratings[id] != nil
        if keyExists {
            return ratings[id]!
        }
        else {
            return "no rating"
        }
    }
    
    func getAddToCalendar() -> Bool {
        return UserDefaults.standard.bool(forKey: "addToCalendar")
    }
    
    func getDaysBetween() -> Int {
        let dateSet = Date()
        let dateOff = getDayOfNotification()
        
        return (dateOff - dateSet).day!
    }
    
    func saveSettings(postcode: String, distance: Double, useCurrentLocation: Bool) {
        setPostcode(p: postcode)
        setDistance(d: distance)
        setLocationSetting(ls: useCurrentLocation)
    }
    
    func saveSettings(postcode: String, distance: Double, useCurrentLocation: Bool, dayOff: Date) {
        setPostcode(p: postcode)
        setDistance(d: distance)
        setLocationSetting(ls: useCurrentLocation)
        setDayOff(d: dayOff)
    }
}

// Source: https://stackoverflow.com/questions/50950092/calculating-the-difference-between-two-dates-in-swift
extension Date {
    
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
}
