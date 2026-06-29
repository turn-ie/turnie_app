import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    @State private var hue: Double = 0
    @State private var brightness: Double = 50
    @State private var name: String = ""
    @State private var hometown: String = ""
    @State private var selectedMotion: MotionType = .ripple
    @State private var hasLoadedSettings = false
    
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
                            "motion": selectedMotion.rawValue,
                            "name": name,
                            "hometown": hometown
                        ]
                        bleManager.sendJSON(json)
                        
                        UserDefaults.standard.set(hue, forKey: "lastSentHue")
                        UserDefaults.standard.set(brightness, forKey: "lastSentBrightness")
                        UserDefaults.standard.set(selectedMotion.rawValue, forKey: "lastSentMotion")
                        UserDefaults.standard.set(hometown, forKey: "lastSentHometown")
                        
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
                hasLoadedSettings = false
                
                if bleManager.isConnected {
                    name = bleManager.deviceName
                }
                hue = UserDefaults.standard.double(forKey: "lastSentHue")
                if UserDefaults.standard.object(forKey: "lastSentBrightness") != nil {
                    brightness = UserDefaults.standard.double(forKey: "lastSentBrightness")
                } else {
                    brightness = 50
                }
                if let lastMotionStr = UserDefaults.standard.string(forKey: "lastSentMotion"),
                   let lastMotion = MotionType(rawValue: lastMotionStr) {
                    selectedMotion = lastMotion
                } else {
                    selectedMotion = .ripple
                }
                hometown = UserDefaults.standard.string(forKey: "lastSentHometown") ?? ""
                
                if bleManager.isConnected {
                    bleManager.requestSettings()
                }
            }
            .onReceive(bleManager.$latestSettings) { settings in
                guard let settings = settings else { return }
                guard !hasLoadedSettings else { return }
                
                if let nameVal = settings.name {
                    self.name = nameVal
                }
                if let hueVal = settings.hue {
                    self.hue = Double(hueVal)
                    UserDefaults.standard.set(hueVal, forKey: "lastSentHue")
                }
                if let brightnessVal = settings.brightness {
                    self.brightness = Double(brightnessVal)
                    UserDefaults.standard.set(brightnessVal, forKey: "lastSentBrightness")
                }
                if let motionVal = settings.motion, let motionType = MotionType(rawValue: motionVal) {
                    self.selectedMotion = motionType
                    UserDefaults.standard.set(motionVal, forKey: "lastSentMotion")
                }
                if let hometownVal = settings.hometown {
                    self.hometown = hometownVal
                    UserDefaults.standard.set(hometownVal, forKey: "lastSentHometown")
                }
                
                hasLoadedSettings = true
            }
        }
    }
}

#Preview {
    SettingsView(isPresented: .constant(true))
        .environmentObject(BLEManager())
}
