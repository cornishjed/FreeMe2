//
//  SubmitActivityView.swift
//  FreeMe2
//
//  Created by Jed Powell on 07/03/2022.
//

import SwiftUI

struct SubmitActivityView: View {
    
    let activityType = ["Art", "Crafts", "Entertainment", "Freedom", "Games", "Learning", "Nature", "Outdoors", "Recreation", "Sports"]
    
    @State var uuid = UUID().uuidString
    @State var name: String = ""
    @State var description: String = ""
    @State var author: String = ""
    @State var postcode: String = ""
    @State var type: String = ""
    @State var weblink: String = ""
    @State var wetWeather: Bool = true
    @State var selectedActivityIndex = 0
    @State private var buttonClicked: Bool = false
    
    @ObservedObject private var viewModel = FirestoreManager()
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("\n*Please fill in all boxes")
                Form {
                    TextField("activity name - place", text: $name)
                    TextField("description", text: $description)
                    TextField("author", text: $author)
                    TextField("postcode e.g. SW1A 1AA", text: $postcode)
                    TextField("weblink", text: $weblink)
                    Picker(selection: $selectedActivityIndex, label: Text("Activity Type")) {
                        ForEach(0 ..< activityType.count) {
                            Text(self.activityType[$0]).tag($0)
                        }
                    } 
                    Toggle("Wet weather friendly", isOn: $wetWeather).onChange(of: wetWeather) { value in
                    }
                    HStack {
                        Spacer()
                    Text("NOTICE")
                        .font(.title3)
                        .foregroundColor(.red)
                        Spacer()
                    }
                    Text("By tapping the button below you confirm that the activity details are correct at the time of submission and agree not to submit false details that threaten the intergrity of the service provided. Submissions available for other users to view pending moderation and validation checks.")
                        .font(.caption)
                    Section {
                        if !buttonClicked {
                            Button("Submit Activity") {
                                if postcode.count > 8 {
                                    let index = postcode.index(postcode.startIndex, offsetBy: 8)
                                    let postcodeSub = postcode[..<index]
                                    postcode = String(postcodeSub)
                                }
                                guard self.name != "" else {return}
                                let name = self.name
                                let type = self.activityType[self.selectedActivityIndex]
                                let description = self.description
                                let author = self.author
                                if (postcode.range(of: #"^([A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}|GIR ?0A{2})$"#, options: .regularExpression) != nil) {// true
                                    _ = self.postcode
                                }
                                else {
                                    self.postcode = ""
                                    return
                                }
                                let weblink = self.weblink
                                let wetWeather = self.wetWeather
                                let newActivity = Activity(id: uuid, name: name, type: type, description: description, postcode: postcode, weblink: weblink, wetWeather: wetWeather, author: author, approved: false)
                                
                                viewModel.addActivity(newActivity)
                                print("Activity saved.")
                                buttonClicked = true
                            }
                            .disabled(name.isEmpty || description.isEmpty || author.isEmpty || postcode.isEmpty || weblink.isEmpty)
                        }
                        if buttonClicked {
                            Text("Activity submitted.")
                            NavigationLink (destination: MainView(localActivities: [Activity]())) {
                                Text("Return")
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationBarTitle("Add Activity")
            .padding(EdgeInsets(top: 0.0, leading: 50.0, bottom: 0.0, trailing: 50.0))
            .frame(width: 500, height: 700, alignment: .bottom)
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubmitActivityView()
        }
    }
}
