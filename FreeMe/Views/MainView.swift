//
//  MainView.swift
//  FreeMe2
//
//  Created by Jed Powell on 05/03/2022.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("firstTime") var firstTime: Bool = true
    @AppStorage("distanceBetween") var distanceBetween = 0
    
    @ObservedObject private var firestoreViewModel = FirestoreManager()
    
    var locationManager = LocationManager()
    @State var localActivities: [Activity]
    @State var settings = Settings()
    
    var body: some View {
        ZStack {
            Image("design1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 750, alignment: .bottom)
            VStack {
                Spacer()
                if !settings.getLocationSetting() {
                    HStack {
                        Spacer()
                        Text("Postcode: \(settings.getPostcode().uppercased())")
                        Spacer()
                        Text("Range: \(settings.getDistance()) miles")
                        Spacer()
                    }
                }
                else if settings.getLocationSetting() {
                    Text("Using current location. Range: \(settings.getDistance()) miles")
                }
                if !localActivities.isEmpty {
                    List(localActivities) { activity in
                        NavigationLink (destination: DetailView(activity:  activity)) {
                            ActivityRow(activity: activity)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    .scaledToFit()
                    .padding()
                }
                else {
                    HStack {
                        Text("There's nothing here 😕\n\nIf Refresh does not work try these:\n1. Check network connection \n2. Enter Settings and select 'Use Postcode', 'Use Current Location' or try different search parameters...")
                    }
                    .padding()
                }
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                        .foregroundColor(.blue)
                    Button("Refresh") {
                        self.firestoreViewModel.fetchData()
                        localActivities = []
                        for item in firestoreViewModel.activities {
                            if !settings.getLocationSetting() {
                                let distance = self.locationManager.getDistanceBetweenCoordinates(postcode: self.settings.getPostcode(), activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                                let userRange = settings.getDistance()
                                print(distance)
                                if ((distance <= userRange) && (distance != 0)) {
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
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    if #available(iOS 15.0, *) {
                        NavigationLink ( destination: SubmitActivityView()) {
                            Text("Add Activity")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        // Fallback on earlier versions
                    }
                    Spacer()
                    if #available(iOS 15.0, *) {
                        NavigationLink ( destination: SetupView(notificationSet: false, dateInvalid: true, text: String(), localActivities: [Activity]())) {
                            Text(" Settings    ")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        // Fallback on earlier versions
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 0.0, leading: 20.0, bottom: 50.0, trailing: 0.0))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitle("Activities")
            }
        }
        .onAppear() {
            print("bug test")
        }
        .onAppear() {
            // Bug: doesn't always work or work properly, so refresh button added as a workaround.
            self.firestoreViewModel.fetchData()
            localActivities = []
            for item in firestoreViewModel.activities {
                if !settings.getLocationSetting() {
                    let distance = self.locationManager.getDistanceBetweenCoordinates(postcode: self.settings.getPostcode(), activityLatitude: item.latitude!, activityLongitude: item.longitude!)
                    let userRange = settings.getDistance()
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
            }
        }
        .onAppear() {
            UserDefaults.standard.set(firstTime, forKey: "firstTime")
        }
    }
    
}


struct ActivityRow: View {
    let activity: Activity
    var settings = Settings()
    
    var body: some View {
        VStack {
            Text(activity.name)
                .fontWeight(.bold)
            HStack {
                Spacer()
                Text(iconImageActivity[activity.type] ?? "")
                Spacer()
                Text(activity.type)
                Spacer()
                Text("\(settings.getRatingFromId(id: activity.id))")
                Spacer()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView(localActivities: [Activity]())
        }
    }
    
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

