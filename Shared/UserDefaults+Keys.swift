import Foundation

public extension UserDefaults {
    static let isAllowRemoteNotificationKey: String = "isAllowRemoteNotification"
    static let isAllowLocalNotificationKey: String = "isAllowLocalNotification"
    static let isIgnoreIDKey: String = "isIgnoreIDKey"

    var isAllowRemoteNotification: Bool {
        get {
            return object(
                forKey: UserDefaults.isAllowRemoteNotificationKey
            ) as? Bool ?? true
        }
        set { set(newValue, forKey: UserDefaults.isAllowRemoteNotificationKey) }
    }

    var isAllowLocalNotification: Bool {
        get {
            return object(
                forKey: UserDefaults.isAllowLocalNotificationKey
            ) as? Bool ?? true
        }
        set { set(newValue, forKey: UserDefaults.isAllowLocalNotificationKey) }
    }

    var isIgnoreID: Bool {
        get {
            return object(
                forKey: UserDefaults.isIgnoreIDKey
            ) as? Bool ?? false
        }
        set { set(newValue, forKey: UserDefaults.isIgnoreIDKey) }
    }
}
