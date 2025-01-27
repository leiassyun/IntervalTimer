import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Close button on the left
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(appearanceManager.backgroundColor)
                            .padding(2)
                            .background(Circle().fill(Color.gray.opacity(0.6)))
                            .frame(width: 16, height: 16)
                    }
                    Spacer() // Pushes the button to the left
                }
                
                // Title centered
                Text("Share")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            
            Spacer()
            Text("Anyone with this link will be able to view the preset")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button(action: {
                print("Share action triggered")
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(appearanceManager.backgroundColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}
