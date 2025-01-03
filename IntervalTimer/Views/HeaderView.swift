import SwiftUI

struct PresetHeaderView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    let totalDuration: String
    
    var body: some View {
        HStack {
            Text("New Preset")
                .font(.system(.title2, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
            Spacer()
            Text("Total: \(totalDuration)")
                .font(.system(.headline, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
        }
        .padding(.horizontal)
        .padding(.top)
        .background(appearanceManager.backgroundColor)
    }
}
