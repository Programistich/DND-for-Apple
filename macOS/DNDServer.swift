import Foundation
import Vapor

final class DNDServer {
    let dndService = DNDService.shared
    static let shared = DNDServer()

    private let app = Application(Environment(name: "development", arguments: ["serve"]))
    private let serverQueue = DispatchQueue(label: "DNDServerQueue", qos: .background)

    func start() {
        app.http.server.configuration.port = 8088

        app.get("dnd") { req async -> Response in
            guard let statusRaw = req.query[String.self, at: "status"] else {
                return Response(status: .badRequest, body: .init(string: "Not status"))
            }

            guard let id = req.query[String.self, at: "id"] else {
                return Response(status: .badRequest, body: .init(string: "Not id"))
            }

            guard let mode = FocusMode(statusRaw) else {
                return Response(status: .badRequest, body: .init(string: "Invalid 'status' value. Use 'on' or 'off'."))
            }

            if UserDefaults.standard.isAllowLocalNotification {
                self.dndService.onChange(mode: mode, by: id)
            }

            return Response(status: .ok, body: .init(string: "MacOS changed DND mode to \(mode)"))
        }

        serverQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.app.run()
            } catch {
                print("Error starting the Vapor application: \(error)")
            }
        }
    }

    func close() {
        app.shutdown()
    }
}
