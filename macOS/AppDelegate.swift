import SwiftUI
import UserNotifications

import FirebaseCore
import FirebaseMessaging

final class AppDelegate: NSObject, NSApplicationDelegate  {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let dndService = DNDService.shared
    private let dndServer = DNDServer.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                NSApplication.shared.registerForRemoteNotifications()
            }
        }

        dndServer.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        dndServer.close()
    }

    func application(
        _ application: NSApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("APNS Token \(deviceToken.reduce("", { $0 + String(format: "%02x", $1)}))")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: NSApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Unable to register for remote notifications: \(error)")
    }

    func application(
        _ application: NSApplication,
        didReceiveRemoteNotification userInfo: [String : Any]
    ) {
        guard UserDefaults.standard.isAllowRemoteNotification else {
            print("Ignore remote")
            return
        }

        guard
            let dndRaw = userInfo["dnd"] as? String,
            let mode = FocusMode(dndRaw),
            let id = userInfo["id"] as? String
        else {
            return
        }

        print("Receive mode \(mode)")
        dndService.onChange(mode: mode, by: id)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken else { return }
        print("FCM Token: \(fcmToken)")

        Task {
            do {
                try await NotificationTokenService.shared.sendToken(fcmToken)
            } catch {
                print("Error sending FCM token: \(error)")
            }
        }
    }
}
