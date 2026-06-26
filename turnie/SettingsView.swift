import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    @State private var hue: Double = 0
    @State private var brightness: Double = 50
    @State private var name: String = ""
    @State private var hometown: String = ""
    @State private var selectedMotion: MotionType = .ripple
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        MotionPreview(type: selectedMotion, hue: hue, brightness: brightness)
                            .frame(width: 160, height: 160)
                            .background(Color.black)
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                        
                        Picker("Motion Type", selection: $selectedMotion) {
                            ForEach(MotionType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section(header: Text(NSLocalizedString("Settings_Hue", comment: "Hue section"))) {
                    HStack {
                        Slider(value: $hue, in: 0...360, step: 1)
                        Circle()
                            .fill(Color(hue: hue / 360, saturation: 1.0, brightness: 1.0))
                            .frame(width: 36, height: 36)
                    }
                }
                
                Section(header: Text(NSLocalizedString("Settings_Brightness", comment: "Brightness section"))) {
                    HStack {
                        Slider(value: $brightness, in: 0...100, step: 1)
                        Text("\(Int(brightness))")
                            .frame(width: 40)
                    }
                }
                
                Section(header: Text(NSLocalizedString("Settings_Name", comment: "Name section"))) {
                    TextField(NSLocalizedString("Settings_Name", comment: "Name placeholder"), text: $name)
                }
                
                Section(header: Text(NSLocalizedString("Settings_Hometown", comment: "Hometown section"))) {
                    TextField(NSLocalizedString("Settings_Hometown", comment: "Hometown placeholder"), text: $hometown)
                }
                
                Section {
                    Button(action: {
                        let json: [String: Any] = [
                            "flag": "settings",
                            "hue": Int(hue),
                            "brightness": Int(brightness),
                            "name": name,
                            "hometown": hometown
                        ]
                        bleManager.sendJSON(json)
                        isPresented = false
                    }) {
                        Text(NSLocalizedString("Settings_SendButton", comment: "Send settings button"))
                            .frame(maxWidth: .infinity)
                            .alignmentGuide(.leading) { _ in 0 }
                    }
                    .buttonStyle(AccentProminentButtonStyle())
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle(NSLocalizedString("Settings_NavigationTitle", comment: "Settings view title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                if bleManager.isConnected {
                    name = bleManager.deviceName
                }
            }
        }
    }
}

#Preview {
    SettingsView(isPresented: .constant(true))
        .environmentObject(BLEManager())
}
