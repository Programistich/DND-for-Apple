import Foundation
import AppKit
import ManagedSettings
import FamilyControls

final class DNDService: ObservableObject {
    static let shared = DNDService()
    private var cache: [String] = []

    private init() {}

    func onChange(mode: FocusMode, by id: String) {
        if cache.contains(id) {
            print("ID already uses")
            return
        } else {
            cache.append(id)
        }
        onChange(mode: mode)
    }

    func onChange(mode: FocusMode) {
        let scheme = "shortcuts://run-shortcut"

        let name: String
        switch mode {
        case .on:
            name = "Set Focus On"
        case .off:
            name = "Set Focus Off"
        }
        let url = URL(string: "\(scheme)?name=\(name)")!
        NSWorkspace.shared.open(url)

        print("Focus changed to \(mode)")
    }
}
