import UIKit
import UserNotifications
import FamilyControls

import FirebaseCore
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let authorizationService = AuthorizationCenter.shared

    private let dndService = DNDService.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        Task { @MainActor in
            do {
                try await authorizationService.requestAuthorization(for: .individual)
            } catch {
                print("Failed to get authorization: \(error)")
            }
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard UserDefaults.standard.isAllowRemoteNotification else {
            print("Ignore remote")
            completionHandler(.noData)
            return
        }

        guard
            let dndRaw = userInfo["dnd"] as? String,
            let mode = FocusMode(dndRaw),
            let id = userInfo["id"] as? String
        else {
            completionHandler(.noData)
            return
        }

        print("Receive mode \(mode)")
        dndService.onChange(mode: mode, by: id)
        completionHandler(.newData)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("APNS Token \(deviceToken.reduce("", { $0 + String(format: "%02x", $1)}))")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Unable to register for remote notifications: \(error)")
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return []
    }
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
