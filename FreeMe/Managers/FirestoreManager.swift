//
//  FirestoreManager.swift
//  FreeMe
//
//  Created by Jed Powell on 02/03/2022.
//  modified from 'add data to Firebase': https://peterfriese.dev/posts/swiftui-firebase-add-data/

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class FirestoreManager: ObservableObject {
    
    @Published var activities = [Activity]()
    @Published var activity: Activity
    @Published var modified = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init(activity: Activity = Activity(id: "", name: "", type: "", description: "", postcode: "", weblink: "", wetWeather: true, author: "", approved: false, latitude: 0, longitude: 0)) {
        self.activity = activity
        
        self.$activity
            .dropFirst()
            .sink {[weak self] book in
                self?.modified = true
            }
            .store(in: &self.cancellables)
    }
    
    func fetchData() {
        db.collection("activity").whereField("approved", isEqualTo: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.activities = documents.map { (queryDocumentSnapshot) -> Activity in
                let id = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let type = data["type"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let postcode = data["postcode"] as? String ?? ""
                let weblink = data["weblink"] as? String ?? ""
                let wetWeather = data["wetWeather"] as? Bool ?? false
                let author = data["author"] as? String ?? ""
                let latitude = data["latitude"] as? Double ?? 0
                let longitude = data["longitude"] as? Double ?? 0
                
                return Activity(id: id, name: name, type: type, description: description, postcode: postcode, weblink: weblink, wetWeather: wetWeather, author: author, approved: true, latitude: latitude, longitude: longitude)
            }
        }
    }
    
    func addActivity(_ activity: Activity) {
        // make timestamp
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full

        let uploadDate = formatter.string(from: now)
        
        let docData:[String: Any] = [
            "dateAdded" : uploadDate, "name" : activity.name, "type" : activity.type, "description" : activity.description, "author": activity.author, "postcode" : activity.postcode, "weblink" : activity.weblink, "wetWeather" : activity.wetWeather, "approved" : false, "latitude" : 0, "longitude" : 0]
        
        // the unique document id is generated by Swift before uploading
        let docRef = db.collection("activity").document(activity.id)
        
        docRef.setData(docData) {error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document written")
            }
        }
    }
    
    func save() {
        addActivity(self.activity)
    }
    
    func handleDoneTapped() {
        self.save()
    }
}
