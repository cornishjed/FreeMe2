//
//  NotificationManager.swift
//  FreeMe2
//
//  Created by Jed Powell on 09/03/2022.
//
//  Created using: https://stackoverflow.com/questions/65967570/swiftui-ask-push-notifications-permissions-again

import SwiftUI //for AppStorage access
import UserNotifications

class NotificationManager: ObservableObject {
    var eventManager = EventsCalendarManager()
    @AppStorage("isButtonEnabled") var isbuttonEnabled: Bool = false
    
    static var appSettings = Settings()
    
    func getAuthorization() {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus == .authorized {
                //NotificationManager.appSettings.setLocationSetting(ls: true)
            }
                center.requestAuthorization(options: [.alert, .sound], completionHandler: {
                    granted, error in
                    if granted && error == nil {
                        //NotificationManager.appSettings.setLocationSetting(ls: true)
                    } else {
                        NotificationManager.appSettings.setLocationSetting(ls: false)
                    }
                })
        })
    }
    
    func postNotification(activity: Activity, wet: Bool) -> Bool {
        // 1. identifier
        let uuidString = UUID().uuidString
        
        // 2. content
        let content = UNMutableNotificationContent()
        
        if wet {
            content.title = "A free day ahead, but it's wet ☂️ This looks like a safe bet!"
        }
        else {
            content.title = "No rain ahead on your day off! Try this activity 🙂"
        }
        
        content.body = activity.name + "\n" + activity.weblink
        
        
        // 3. trigger
        let calendar = Calendar.current
        
        // back to components for trigger
        let dayOffNotify = NotificationManager.appSettings.getDayOfNotification()
        let dayOffNotifyComponents = DateComponents(timeZone: TimeZone(abbreviation: "UTC+01:00"),
                                                    year: calendar.component(.year, from: dayOffNotify),
                                                    month: calendar.component(.month, from: dayOffNotify),
                                                    day: calendar.component(.day, from: dayOffNotify),
                                                    hour: calendar.component(.hour, from: dayOffNotify),
                                                    minute: calendar.component(.minute, from: dayOffNotify))
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dayOffNotifyComponents, repeats: false)
        
        // 4. construct notification
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        
        // 5. add notification
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error creating notification")
            }
            else {
                print("Notification created")
            }
        }
        
        // optional add to calendar
        if NotificationManager.appSettings.getAddToCalendar() {
            // default event time in calendar set from 9am to 5pm
            let dayOff = NotificationManager.appSettings.getDayOff()
            
            var dayOffStartTime = DateComponents(timeZone: TimeZone(abbreviation: "UTC+01:00"),
                                                 year: calendar.component(.year, from: dayOff),
                                                 month: calendar.component(.month, from: dayOff),
                                                 day: calendar.component(.day, from: dayOff))
            
            dayOffStartTime.hour = 09
            dayOffStartTime.minute = 00
            
            var dayOffEndTime = DateComponents(timeZone: TimeZone(abbreviation: "UTC+01:00"),
                                               year: calendar.component(.year, from: dayOff),
                                               month: calendar.component(.month, from: dayOff),
                                               day: calendar.component(.day, from: dayOff))
            
            dayOffEndTime.hour = 17
            dayOffEndTime.minute = 00
            
            //DateComponents converted to Date before passing through eventManager
            eventManager.createEventinTheCalendar(with: activity.name, forDate: NSCalendar.current.date(from: dayOffStartTime)!, toDate: NSCalendar.current.date(from: dayOffEndTime)!)
        }
        return true
    }
}
