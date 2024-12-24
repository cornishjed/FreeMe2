//
//  Activity.swift
//  FreeMe
//
//  Created by Jed Powell on 13/02/2022.
//

import Foundation

let defaultIconActivity = " ? "

// may omit icons

let iconImageActivity = [
    "Art" : "🎨",
    "Crafts" : "🧶",
    "Entertainment" : "🎭",
    "Games" : "🎯",
    "Learning" : "📚",
    "Nature" : "🌳",
    "Recreation" : "🧗‍♂️",
    "Outdoors" : "⛲️",
    "Sports" : "⚽️"]

struct Activity: Identifiable, Codable {
    var id: String
    var name: String
    var type: String
    var description: String
    var postcode: String
    var weblink: String
    var wetWeather: Bool
    var author: String
    var approved: Bool
    var latitude: Double?
    var longitude: Double?
}

let activities = [
    Activity(id: "989009", name: "Gorse covert", type: "Walk", description: "NKJNKJWNDKJWBDKJWBKBKJ", postcode: "HJK67 HUJKH7", weblink: "google.com", wetWeather: false, author: "jed", approved: true, latitude: 0, longitude: 0)
]
