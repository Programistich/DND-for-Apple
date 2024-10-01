import Foundation
import ManagedSettings
import FamilyControls

final class DNDService: ObservableObject {
    static let shared = DNDService()

    private let store = ManagedSettingsStore()
    private var cache: [String] = []
    @Published var isBlocked: Bool

    private init() {
        self.isBlocked = store.shield.applicationCategories != nil
    }

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
        switch mode {
        case .on:
            isBlocked = true
            store.shield.applicationCategories = .all(except: [])
        case .off:
            isBlocked = false
            store.shield.applicationCategories = nil
        }
        print("Focus changed to \(mode)")
    }
}
