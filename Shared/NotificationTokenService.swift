import Foundation

class NotificationTokenService {
    static let shared = NotificationTokenService()

    private let url = "https://dnd.kulikov.uk"

    func sendToken(_ token: String) async throws {
        let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let requestUrl = URL(string: url + "/register?token=\(encodedToken)")!

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
        print("DNDService added token with response: \(String(data: data, encoding: .utf8)!)")
    }
}
