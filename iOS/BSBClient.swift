import SwiftUI
import Network

class BSBClient: ObservableObject {
    @Published var receivedMessages: [String] = []
    @Published var services: [NWBrowser.Result] = []
    @Published var connectionStatus: Status = .disconnected

    private var browser: NWBrowser?
    private var connection: NWConnection?
    private let serviceType = "_bsb._tcp"
    private let serviceDomain = "local."

    enum Status: Equatable {
        static func == (lhs: BSBClient.Status, rhs: BSBClient.Status) -> Bool {
            if case .disconnected = lhs, case .disconnected = rhs {
                return true
            }
            if case .connecting = lhs, case .connecting = rhs {
                return true
            }
            if case .connected = lhs, case .connected = rhs {
                return true
            }
            if case .error = lhs, case .error = rhs {
                return true
            }
            if case .cancelled = lhs, case .cancelled = rhs {
                return true
            }
            if case .closed = lhs, case .closed = rhs {
                return true
            }
            return false
        }

        case disconnected
        case connecting
        case connected
        case error(Error)
        case cancelled
        case closed
    }

    deinit {
        stopBrowsing()
        disconnect()
    }

    func reset() {
        disconnect()
        stopBrowsing()
        startBrowsing()
    }

    func startBrowsing() {
        let parameters = NWParameters.tcp
        browser = NWBrowser(
            for: .bonjour(type: serviceType, domain: serviceDomain),
            using: parameters
        )

        browser?.stateUpdateHandler = { newState in
            print("Browser state changed to: \(newState)")
        }

        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            DispatchQueue.main.async {
                self?.services = Array(results)
            }
        }

        browser?.start(queue: .main)
    }

    private func stopBrowsing() {
        browser?.cancel()
        browser = nil
    }

    func connect(to service: NWBrowser.Result) {
        let parameters = NWParameters.tcp
        connection = NWConnection(to: service.endpoint, using: parameters)

        connection?.stateUpdateHandler = { [weak self] newState in
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    self?.connectionStatus = .connected
                    print("Connected to service")
                    self?.receiveMessages()
                case .failed(let error):
                    self?.connectionStatus = .error(error)
                    print("Connection failed: \(error)")
                case .cancelled:
                    self?.connectionStatus = .cancelled
                    print("Connection cancelled")
                default:
                    break
                }
            }
        }

        connection?.start(queue: .main)
    }

    private func disconnect() {
        connection?.cancel()
        connection = nil
        connectionStatus = .disconnected
        services = []
        receivedMessages = []
    }

    private func receiveMessages() {
        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [weak self] data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                if let message = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self?.processMessage(message)
                        self?.receivedMessages.append(message)
                    }
                }
            }
            if let error = error {
                DispatchQueue.main.async {
                    self?.connectionStatus = .error(error)
                }
                print("Receive error: \(error)")
                return
            }
            if isComplete {
                DispatchQueue.main.async {
                    self?.connectionStatus = .closed
                }
                self?.connection?.cancel()
                return
            }
            self?.receiveMessages()
        }
    }

    private func processMessage(_ message: String) {
        print("Received message: \(message)")
        let split = message.split(separator: " ")

        let dndRaw = split[0].trimmingCharacters(in: .whitespaces)
        let id = split[1].trimmingCharacters(in: .whitespaces)
        guard let mode = FocusMode(dndRaw) else { return }

        guard UserDefaults.standard.isAllowLocalNotification else {
            print("Ignore local")
            return
        }

        DNDService.shared.onChange(mode: mode, by: id)
    }
}
