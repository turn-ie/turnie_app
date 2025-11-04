import SwiftUI

struct AccentProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    enum HeightMode { case fit, large }
    enum WidthMode { case fit, full }

    var heightMode: HeightMode = .large
    var widthMode: WidthMode = .full

    init(heightMode: HeightMode = .large, widthMode: WidthMode = .full) {
        self.heightMode = heightMode
        self.widthMode = widthMode
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, heightMode == .large ? 16 : 10)
            .frame(maxWidth: widthMode == .full ? .infinity : nil)
            .background(.accent)
            .cornerRadius(.infinity)
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.8 : (isEnabled ? 1.0 : 0.4))
    }
}
