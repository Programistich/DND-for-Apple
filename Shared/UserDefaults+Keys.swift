import Foundation

public extension UserDefaults {
    static let isAllowRemoteNotificationKey: String = "isAllowRemoteNotification"
    static let isAllowLocalNotificationKey: String = "isAllowLocalNotification"

    var isAllowRemoteNotification: Bool {
        get {
            return object(
                forKey: UserDefaults.isAllowRemoteNotificationKey
            ) as? Bool ?? true
        }
        set { set(newValue, forKey: UserDefaults.isAllowLocalNotificationKey) }
    }

    var isAllowLocalNotification: Bool {
        get {
            return object(
                forKey: UserDefaults.isAllowLocalNotificationKey
            ) as? Bool ?? true
        }
        set { set(newValue, forKey: UserDefaults.isAllowLocalNotificationKey) }
    }
}
