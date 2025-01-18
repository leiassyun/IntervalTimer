import SwiftUI

struct ShareView: View {
    let preset: Preset
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var presetManager: PresetManager
    @State private var shareURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Close button on the left
                HStack {
                    AppButton(
                        title: "",
                        icon: "xmark",
                        type: .textOnly,
                        isFullWidth: false
                    ) {
                        dismiss()
                    }
                    
                    Spacer()
                }
                
                // Title centered
                Text("Share")
                    .font(.system(.title2, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("Anyone with this link will be able to view the preset")
                .font(.system(.body))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            if let shareURL = shareURL {
                ShareLink(
                    item: shareURL,
                    subject: Text("Check out my workout preset!"),
                    message: Text("I've been using this great workout preset for my intervals. Try it out!")
                ) {
                    AppButton(
                        title: "Share",
                        icon: "square.and.arrow.up",
                        type: .primary,
                        isFullWidth: true
                    ) {
                        // ShareLink handles the action
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Unable to generate a shareable URL.")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(appearanceManager.backgroundColor)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            shareURL = ShareManager.generateShareURL(for: preset)
        }
    }
}
