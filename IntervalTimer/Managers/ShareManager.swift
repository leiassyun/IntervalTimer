import Foundation
import UIKit

class ShareManager {
    static func generateShareURL(for preset: Preset) -> URL? {
        do {
            let jsonData = try JSONEncoder().encode(preset)
            // Base64 encode the JSON data:
            let base64EncodedPreset = jsonData.base64EncodedString()
            
            var components = URLComponents()
            components.scheme = "intervaltimer"
            components.host = "share"
            components.queryItems = [
                URLQueryItem(name: "preset", value: base64EncodedPreset)
            ]
            
            return components.url
        } catch {
            print("Failed to generate share URL: \(error)")
            return nil
        }
    }
    
    static func handleIncomingURL(_ url: URL, completion: @escaping (Result<Preset, Error>) -> Void) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let presetString = components.queryItems?.first(where: { $0.name == "preset" })?.value else {
            let err = NSError(domain: "ShareManager", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid URL or missing preset data."])
            completion(.failure(err))
            return
        }
        
        
        // Directly decode from Base64:
        guard let jsonData = Data(base64Encoded: presetString) else {
            let err = NSError(domain: "ShareManager", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to decode Base64 data."])
            completion(.failure(err))
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
