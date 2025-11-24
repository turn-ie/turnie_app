import SwiftUI

struct DashboardButtonStyle: ButtonStyle {
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
    }
}

