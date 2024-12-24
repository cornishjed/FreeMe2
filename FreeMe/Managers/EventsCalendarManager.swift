// Source: https://iostutorialjunction.com/2017/09/add-event-to-device-calendar-ios-swift.html

import UIKit
import EventKit
import EventKitUI

class EventsCalendarManager: NSObject {
    let store = EKEventStore()
    
    func createEventinTheCalendar(with title:String, forDate eventStartDate:Date, toDate eventEndDate:Date) {
            
            store.requestAccess(to: .event) { (success, error) in
                if  error == nil {
                    let event = EKEvent.init(eventStore: self.store)
                    event.title = title
                    event.calendar = self.store.defaultCalendarForNewEvents // this will return default calendar from device calendars
                    event.startDate = eventStartDate
                    event.endDate = eventEndDate
                    
                    let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                    event.addAlarm(alarm)
                    
                    do {
                        try self.store.save(event, span: .thisEvent)
                        //event created successfullt to default calendar
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                    }

                } else {
                    //we have error in getting access to device calnedar
                    print("error = \(String(describing: error?.localizedDescription))")
                }
            }
        }
    
}
