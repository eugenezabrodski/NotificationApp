//
//  Notifications.swift
//  NotificationApp
//
//  Created by Eugene on 05/01/2024.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            print("\(settings)")
        }
    }
    
    func scheduleNotification(notificationType: String) {
        let content = UNMutableNotificationContent()
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let userAction = "User Action"
        
        content.title = notificationType
        content.body = "This is exapmle how to create " + notificationType
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        guard let path = Bundle.main.path(forResource: "favicon", ofType: "png") else { return }
        let url = URL(fileURLWithPath: path)
        
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "favicon", url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment could not be load")
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: triger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(
            identifier: userAction,
            actions: [snoozeAction, deleteAction],
            intentIdentifiers: [],
            options: [])
        notificationCenter.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notification with the Local Notification Identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss action")
        case UNNotificationDismissActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete")
        default:
            print("unknown Action")
        }
        
        completionHandler()
    }
}
