//
//  ContentView.swift
//  FreeMe2
//
//  Created by Jed Powell on 03/03/2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            if !isAppAlreadyLaunchedOnce() {
                NavigationLink ( destination: IntroductionView(weatherViewModel: WeatherViewModel(weatherService: WeatherService()))) {
                    VStack {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                        Text("The Free Time Planning Assistant for Busy\nPeople")
                            .padding()
                    }
                }
            }
            else {
                NavigationLink (destination: MainView(localActivities: [Activity]())) {
                    VStack {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                        Text("The Free Time Planning Assistant for Busy\nPeople")
                            .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
// Source: https://stackoverflow.com/questions/26830285/how-to-detect-apps-first-launch-in-ios
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "firstTimeLaunch") {
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "firstTimeLaunch")
            print("App launched first time")
            return false
        }
    }
    // Source end
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
