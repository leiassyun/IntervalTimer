import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {} 

    func playSound(named fileName: String, withExtension fileExtension: String = "wav") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Sound file not found: \(fileName).\(fileExtension)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        audioPlayer?.stop()
    }
}
