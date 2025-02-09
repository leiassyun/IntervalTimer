import Foundation
import UIKit

class ShareManager {
    static func generateShareURL(for preset: Preset) -> URL? {
        do {
            let jsonData = try JSONEncoder().encode(preset)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }

            guard let percentEncodedPreset = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

            var components = URLComponents()
            components.scheme = "intervaltimer"
            components.host = "share"
            components.queryItems = [
                URLQueryItem(name: "preset", value: percentEncodedPreset)
            ]
            
            return components.url
        } catch {
            print("Failed to generate share URL: \(error)")
            return nil
        }
    }

    static func handleIncomingURL(_ url: URL, completion: @escaping (Result<Preset, Error>) -> Void) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let presetBase64 = queryItems.first(where: { $0.name == "preset" })?.value,
              let jsonData = Data(base64Encoded: presetBase64) else {
            completion(.failure(NSError(
                domain: "ShareManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL or missing preset data"]
            )))
            return
        }
        
        do {
            let preset = try JSONDecoder().decode(Preset.self, from: jsonData)
            completion(.success(preset))
        } catch {
            completion(.failure(error))
        }
    }
}
