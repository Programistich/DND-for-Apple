import SwiftUI

@main
struct DNDMacOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dndService: DNDService = DNDService.shared

    @AppStorage(UserDefaults.isAllowRemoteNotificationKey)
    private var isAllowRemoteNotification: Bool = true

    @AppStorage(UserDefaults.isAllowLocalNotificationKey)
    private var isAllowLocalNotification: Bool = true

    var body: some Scene {
        MenuBarExtra {
            Button("Start Focus") {
                dndService.onChange(mode: .on)
            }

            Button("Stop Focus") {
                dndService.onChange(mode: .off)
            }

            Toggle(isOn: $isAllowRemoteNotification) {
                Text("Allow Remote")
            }

            Toggle(isOn: $isAllowLocalNotification) {
                Text("Allow Local")
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
        } label: {
            Text("BSB")
        }
    }
}
