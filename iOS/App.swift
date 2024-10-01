import SwiftUI

@main
struct DNDiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var bsbClient = BSBClient()
    @StateObject private var dndService: DNDService = DNDService.shared

    @AppStorage(UserDefaults.isAllowRemoteNotificationKey)
    private var isAllowRemoteNotification: Bool = true

    @AppStorage(UserDefaults.isAllowLocalNotificationKey)
    private var isAllowLocalNotification: Bool = true

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 18) {
                Text("Status BSB: \(bsbClient.connectionStatus)")
                Text("Focus Mode: \(dndService.isBlocked)")

                Toggle(
                    isOn: .init(
                        get: { dndService.isBlocked },
                        set: { dndService.onChange(mode: $0 ? .on : .off) }
                    )
                ) {
                    Text("Change mode")
                }
                .padding(.horizontal, 60)

                Toggle(isOn: $isAllowRemoteNotification) {
                    Text("Allow Remote Notification")
                }
                .padding(.horizontal, 60)

                Toggle(isOn: $isAllowLocalNotification) {
                    Text("Allow Local Notification")
                }
                .padding(.horizontal, 60)

                if bsbClient.connectionStatus == .connected {
                    List(bsbClient.receivedMessages, id: \.self) { message in
                        Text(message)
                    }
                } else {
                    Spacer()
                    ProgressView()
                    Button("Reset") {
                        bsbClient.reset()
                    }
                    Spacer()
                }
            }
            .onChange(of: bsbClient.services) { services in
                guard
                    let bsbService = services.first(
                        where: { $0.endpoint.debugDescription == "BSB._bsb._tcp.local." }
                    )
                else { return }
                bsbClient.connect(to: bsbService)
            }
            .onAppear {
                bsbClient.startBrowsing()
            }
        }
    }
}
