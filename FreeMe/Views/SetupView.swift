//
//  SetupView.swift
//  FreeMe2
//
//  Created by Jed Powell on 03/03/2022.
//

import SwiftUI

struct SetupView: View {
    
    @AppStorage("dayOff") var dayOff: Date = Date()
    @AppStorage("postcode") var postcode: String = ""
    @AppStorage("useCurrentLocation") var useCurrentLocation: Bool = false
    @AppStorage("addToCalendar") var addToCalendar: Bool = false
    @AppStorage("distance") var distance: Double = 20
    
    @ObservedObject var weatherViewModel = WeatherViewModel(weatherService: WeatherService())
    @ObservedObject private var firestoreViewModel = FirestoreManager()
    @ObservedObject var notificationViewModel = NotificationManager()
    var locationManager = LocationManager()
    
    @State var linkClicked = false
    @State var saved = false
    @State var settings = Settings()
    @State var check: Bool = false
    @State var notificationSet: Bool
    @State var dateInvalid: Bool
    @State var text: String
    
    @State var localActivities: [Activity]
    
    var body: some View {
        ZStack {
            Image("design1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 750, alignment: .bottom)
            VStack {
                if !linkClicked {
                    Spacer()
                    HStack {
                        Image(systemName: "location")
                        Text("Location")
                            .font(.title)
                    }
                    HStack {
                        Text("Your area postcode: ")
                        TextField("e.g. BS1 1SS", text: $postcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(EdgeInsets(top: 0.0, leading: 40.0, bottom: 0.0, trailing: 0.0))
                    }
                    HStack {
                        Button("Use Postcode") {
                            text = "disabled"
                            useCurrentLocation = false
                            if postcode.count > 8 {
                                let index = postcode.index(postcode.startIndex, offsetBy: 8)
                                let postcodeSub = postcode[..<index]
                                postcode = String(postcodeSub)
                            }
                            settings.saveSettings(postcode: postcode, distance: distance, useCurrentLocation: useCurrentLocation)
                            saved = true
                            self.firestoreViewModel.fetchData()
                            localActivities = []
                            for item in firestoreViewModel.activities {
                                if !settings.getLocationSetting() {
                                    let distance = self.locationManager.getDistanceBetweenCoordinates(postcode: self.settings.getPostcode(), activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                    let userRange = settings.getDistance()
                                    print(distance)
                                    if ((distance <= userRange) && (distance != -1)) {
                                        // distance of -1 indicates an error
                                        localActivities.append(item)
                                    }
                                }
                                else {
                                    let distance = self.locationManager.getDistanceBetweenCoordinates(activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                    let userRange = settings.getDistance()
                                    if ((distance <= userRange) && (distance != -1)) {
                                        localActivities.append(item)
                                    }
                                }
                            }
                        }
                        .disabled(postcode == "")
                        Text("or")
                        Button("Use Current Location:\n\(text)") {
                            useCurrentLocation = true
                            settings.saveSettings(postcode: postcode, distance: distance, useCurrentLocation: useCurrentLocation)
                            saved = true
                            text = useCurrentLocation ? "enabled" : "disabled"
                        }
                    }
                    .padding()
                    Stepper("Miles from given location:\n\(String(format: "%.0f", distance))", value: $distance, in: 0...200, step: 10)
                    Spacer()
                    Divider()
                    Spacer()
                }
                if linkClicked {
                    Spacer()
                }
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Notification")
                        .font(.title)
                }
                Text("*Current Location only")
                if !linkClicked {
                    DatePicker("Next day off:", selection: $dayOff, in: Date().addingTimeInterval(86400)...Date().addingTimeInterval(432000), displayedComponents: [.date])
                        .datePickerStyle(.compact)
                    Toggle("Add date to calendar:", isOn: $addToCalendar)
                    HStack {
                        Text("\n")
                        Image(systemName: "exclamationmark.bubble")
                        Button("Set Notification") {
                            settings.saveSettings(postcode: postcode, distance: distance, useCurrentLocation: useCurrentLocation, dayOff: dayOff)
                            linkClicked = true
                            
                            /*for item in firestoreViewModel.activities {
                                if !settings.getLocationSetting() {
                                    let distance = self.locationManager.getDistanceBetweenCoordinates(postcode: self.settings.getPostcode(), activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                    let userRange = settings.getDistance()
                                    print(distance)
                                    if (distance <= userRange) {
                                        localActivities.append(item)
                                    }
                                }
                                else {
                                    let distance = self.locationManager.getDistanceBetweenCoordinates(activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                    let userRange = settings.getDistance()
                                    if (distance <= userRange) {
                                        localActivities.append(item)
                                    }
                                }
                            }*/
                            
                            // seperate activities in range. Just from user location until fixed
                            localActivities = []

                            for item in firestoreViewModel.activities {
                                let distance = self.locationManager.getDistanceBetweenCoordinates(activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                let userRange = settings.getDistance()
                                if (distance <= userRange) {
                                    localActivities.append(item)
                                }
                            }
                            
                            // halt operation if date is invalid
                            self.dateInvalid = Calendar.current.isDate(settings.getDayOff(), equalTo: Date(), toGranularity: .day)
                            
                            if self.dateInvalid {
                                return
                            }
                            
                            // prevent infinite loop if no wet-suitable activity found
                            let wetWeatherActivityFound = activities.contains {$0.wetWeather == true}
                            
                            let activityCount = localActivities.count
                            while check == false {
                                // in case of no items/network failure
                                if activityCount <= 0 {
                                    break
                                }
                                else {
                                    let selection = Int.random(in: 0...activityCount - 1)
                                    let daysBetween = settings.getDaysBetween()
                                    
                                    // check weather condition and suitable 'local' activity
                                    if !(weatherViewModel.weathers.isEmpty) {
                                        let weatherOnDayOff = weatherViewModel.weathers[daysBetween*8].weather.description
                                        if !(weatherOnDayOff.contains("drizzle")) || !(weatherOnDayOff.contains("thunderstorm")) || !(weatherOnDayOff.contains("rain")) || !(weatherOnDayOff.contains("snow")) {
                                            self.notificationSet = self.notificationViewModel.postNotification(activity: localActivities[selection], wet: false)
                                            self.check = true
                                            self.notificationSet = true
                                        }
                                        else if ((weatherOnDayOff.contains("drizzle")) || (weatherOnDayOff.contains("thunderstorm")) || (weatherOnDayOff.contains("rain")) || (weatherOnDayOff.contains("snow"))) && (activities[selection].wetWeather) && wetWeatherActivityFound {
                                            self.notificationSet = self.notificationViewModel.postNotification(activity: localActivities[selection], wet: true)
                                            self.check = true
                                            self.notificationSet = true
                                        }
                                    }
                                    else {
                                        print("Weather data unavailable")
                                        self.check = true
                                        self.notificationSet = false
                                    }
                                }
                            }
                        }
                        .disabled(self.useCurrentLocation == false)
                    }
                    Spacer()
                }
                else if self.dateInvalid {
                    Text("\n\nAn error occured. Open the date picker and select a date next time.\n")
                    NavigationLink (destination: MainView(localActivities: self.localActivities)) {
                        Text("Next")
                    }
                    Spacer()
                }
                else if !self.notificationSet {
                    Text("\n\nAn error occured. Please check network connection, app settings and try again.\n")
                    NavigationLink (destination: MainView(localActivities: self.localActivities)) {
                        Text("Next")
                    }
                    Spacer()
                }
                else {
                    Text("\n\nNotification set!\nWe’ll suggest an activity two days in advance of your day off.\nPlease enable notifications in system settings to allow full app functionality\n")
                    NavigationLink (destination: MainView(localActivities: self.localActivities)) {
                        Text("Next")
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Settings")
            .onAppear(perform: {
                notificationViewModel.getAuthorization()
            })
            .onAppear() {
                self.firestoreViewModel.fetchData()
            }
            .onAppear(perform: self.weatherViewModel.refresh)
            .onAppear() {
                text = useCurrentLocation ? "enabled" : "disabled"
                postcode = settings.getPostcode()
                print(postcode)
                useCurrentLocation = settings.getLocationSetting()
            }
            .padding(EdgeInsets(top: 0, leading: 50, bottom: 150, trailing: 50))
        }
        .accentColor(.orange)
    }
}

// https://swiftwombat.com/how-to-store-a-date-using-appstorage-in-swiftui/
// To enable Date() use with @AppStorage

import Foundation

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}


struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupView(weatherViewModel: WeatherViewModel(weatherService: WeatherService()), notificationSet: false, dateInvalid: false, text: String(), localActivities: [Activity]())
        }
    }
}
