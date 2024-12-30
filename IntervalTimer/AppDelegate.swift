import UIKit

//@main // Uncomment this if your app uses UIKit lifecycle instead of SwiftUI's App lifecycle.
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject  {
    var window: UIWindow?
    var presetManager: PresetManager
    
    override init() {
        self.presetManager = PresetManager()
        super.init()
    }
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        do {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  components.host == "share",
                  let queryItems = components.queryItems,
                  let presetItem = queryItems.first(where: { $0.name == "preset" }),
                  let doubleEncodedPreset = presetItem.value else {
                throw NSError(domain: "AppDelegate", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or missing query items."])
            }
            
            let decodedPreset = try decodePreset(from: doubleEncodedPreset)
            presetManager.addPresetP(newPreset: decodedPreset)
            print("Preset added: \(decodedPreset)")
            return true
        } catch {
            print("Error handling URL: \(error.localizedDescription)")
            return false
        }
    }
    
    // Helper function for decoding the preset
    private func decodePreset(from doubleEncodedPreset: String) throws -> Preset {
        // Step 1: First percent-decoding
        guard let firstDecoded = doubleEncodedPreset.removingPercentEncoding else {
            throw NSError(domain: "URLDecoding", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to perform first percent-decoding."])
        }
        print("First Decoded String: \(firstDecoded)")
        
        // Step 2: Second percent-decoding
        guard let secondDecoded = firstDecoded.removingPercentEncoding else {
            throw NSError(domain: "URLDecoding", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to perform second percent-decoding."])
        }
        print("Second Decoded String: \(secondDecoded)")
        
        // Step 3: Convert to Data
        guard let data = secondDecoded.data(using: .utf8) else {
            throw NSError(domain: "URLDecoding", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data."])
        }
        
        // Step 4: Decode into Preset
        do {
            return try JSONDecoder().decode(Preset.self, from: data)
        } catch {
            print("JSON Decoding Error: \(error)")
            throw error
        }
    }
    
    // This function is for testing URL handling
    func testURLHandling(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }
        print("Testing URL: \(url)")

        let result = UIApplication.shared.delegate?.application?(UIApplication.shared, open: url, options: [:])
        print("URL Handling Result: \(result == true ? "Success" : "Failure")")
    }
}
