import SwiftUI

struct DashboardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.quaternarySystemFill))
            )
            .foregroundColor(.accent)
            .aspectRatio(1, contentMode: .fit)
            .opacity(configuration.isPressed ? 0.8 : (isEnabled ? 1.0 : 0.4))
    }
}

