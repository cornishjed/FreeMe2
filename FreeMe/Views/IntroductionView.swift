//
//  IntroductionView.swift
//  FreeMe2
//
//  Created by Jed Powell on 03/03/2022.
//

import SwiftUI

struct IntroductionView: View {
    
    @AppStorage("postcode") var postcode: String = ""
    @AppStorage("useCurrentLocation") var useCurrentLocation: Bool = false
    @AppStorage("distance") var distance: Double = 20
    
    @State var settings = Settings()
    @State var saved = false
    @ObservedObject var weatherViewModel: WeatherViewModel // for getLocationData and authorisation

    var body: some View {
        ZStack {
            VStack {
                Text("We aim to provide you with activity suggestions based on your time off, local area and weather conditions.\n\nEnter location details below to filter activities by range.\n\nEnter the settings menu to activate your timely notification 💬")
                Divider()
                if !saved {
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
                            settings.saveSettings(postcode: postcode, distance: distance, useCurrentLocation: false)
                            saved = true
                        }
                        .disabled(postcode == "")
                        Text("or")
                        Button("Use Current Location") {
                            settings.saveSettings(postcode: "", distance: distance, useCurrentLocation: true)
                            saved = true
                            self.weatherViewModel.refresh()
                        }
                    }
                    .padding()
                    Stepper("Miles from given location:\n\(String(format: "%.0f", distance))", value: $distance, in: 0...200, step: 10)
                }
                else if saved {
                    NavigationLink (destination: MainView(localActivities: [Activity]())) {
                        Text("Next")
                    }
                    .padding(50)
                }
            }
            .padding(EdgeInsets(top: 0.0, leading: 80.0, bottom: 180.0, trailing: 80.0))
            Image("design1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 500, height: 800, alignment: .bottom)
        }
        .navigationBarTitle("Settings")
        .navigationBarBackButtonHidden(true)
    }
    
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntroductionView(weatherViewModel: WeatherViewModel(weatherService: WeatherService()))
        }
    }
}
