//
//  DetailView.swift
//  FreeMe2
//
//  Created by Jed Powell on 14/03/2022.
//

import Foundation
import SwiftUI

struct DetailView: View {
    let activity: Activity
    @State var rating = Int()
    @State var settings = Settings()
    
    var body: some View {
        ZStack {
            Image("design1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 750, alignment: .bottom)
            VStack {
                Section {
                    Text (activity.name)
                        .font(.title)
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    ScrollView {
                        Text(activity.description)
                    }
                    .padding()
                    .frame(height: 400)
                    HStack {
                        Spacer()
                        Text("Type:")
                            .font(.title3)
                        Text(activity.type)
                        Spacer()
                    }
                    HStack {
                        Stepper("Your rating out of 5: \t  \(rating)", value: $rating, in: 0...5)
                        Button("   Set    ") {
                            settings.setRatings(id: activity.id, rating: rating)
                        }
                    }
                    .padding()
                }
                Spacer()
                Section {
                    HStack {
                        Link("Website",
                             destination: URL(string: activity.weblink)!)
                            .font(.title3)
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.blue)
                        }
                    HStack {
                        Button("Google Maps", action: {
                            mapsButton(name: activity.name)
                        })
                            .font(.title3)
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
    
    func mapsButton(name: String) {
        let nameArr = name.components(separatedBy: " ")
        
        var urlActivityName: String = ""
        
        //code to fill spaces in name with +s
        
        for part in nameArr {
            urlActivityName = urlActivityName + part
            urlActivityName = urlActivityName + "+"
        }
        
        let intForIndex = urlActivityName.count - 1
        let index = urlActivityName.index(urlActivityName.startIndex, offsetBy: intForIndex)
        
        urlActivityName.remove(at: index)
        
        // Source: https://codewithchris.com/swiftui/swiftui-google-maps/
        
        let url = URL(string: "comgooglemaps://?q=\(urlActivityName),+GB&center=51.5072,-0.1276&views=satellite,traffic&zoom=15")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        else{
            let urlBrowser = URL(string: "https://www.google.com/maps/search/?api=1&query=\(urlActivityName)")
            
            UIApplication.shared.open(urlBrowser!, options: [:], completionHandler: nil)
        }
        
        //end Source
        
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(activity: activities[0])
        }
    }
}
