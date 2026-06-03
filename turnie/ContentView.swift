import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    @State private var showingDeviceList = false
    @State private var showingTextInput = false
    @State private var showingImageInput = false
    @State private var showingPixelInput = false
    @State private var showingSettings = false
    
    var body: some View {
        
        let gapSize = CGFloat(5)
        let columns = [
            GridItem(.flexible(), spacing: gapSize),
            GridItem(.flexible(), spacing: gapSize)
        ]
        
        NavigationView {
            VStack() {
                        let iconSize = CGFloat(20)
                        LazyVGrid(columns: columns, spacing: gapSize) {
                            Button(action:{bleManager.reconnectToLastDevice()}){
                                ZStack(alignment: .bottomTrailing) {
                                    VStack(alignment: .leading) {
                                        if bleManager.isAutoConnecting {
                                            HStack{
                                                ProgressView()
                                                    .scaleEffect(x: 0.75, y: 0.75, anchor: .center)
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                                Text(
                                                    bleManager.isAutoConnecting
                                                    ? NSLocalizedString("Common_Connecting", comment: "Connecting status")
                                                    : (bleManager.deviceName.isEmpty ? NSLocalizedString("Common_NoDevice", comment: "No device connected") : bleManager.deviceName)
                                                )
                                                .font(.caption)
                                            }
                                        } else {
                                            if bleManager.isConnected {
                                                Text(NSLocalizedString("Common_Connected", comment: "Device is connected"))
                                                    .font(.caption)
                                            } else{
                                                VStack(alignment: .leading) {
                                                    Text(NSLocalizedString("Common_Disconnected", comment: "Device is disconnected"))
                                                        .font(.caption)
                                                    Text(NSLocalizedString("ContentView_TapToReconnect", comment: "Tap to reconnect button"))
                                                        .font(.caption2)
                                                }
                                            }
                                        }
                                        Spacer()
                                        Text(bleManager.deviceName.isEmpty ? NSLocalizedString("Common_NoDevice", comment: "No device connected") : bleManager.deviceName)
                                        
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .padding(20)
                                    .foregroundColor(Color(.white))
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color(.accent))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(bleManager.isConnected)
                            
                            Button(action: {showingTextInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "textformat")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text(NSLocalizedString("ContentView_TextButton", comment: "Text input button"))
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                            
                            Button(action: {showingImageInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "photo")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text(NSLocalizedString("ContentView_PhotoButton", comment: "Photo input button"))
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                            
                            Button(action: {showingPixelInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text(NSLocalizedString("ContentView_CreateButton", comment: "Create pixel art button"))
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)

                            Button(action: {showingSettings = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "gear")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text(NSLocalizedString("ContentView_SettingsButton", comment: "Settings button label"))
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                        }
                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("App_Name", comment: "Application Name"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingDeviceList = true
                            bleManager.startScanning()
                        }) {
                            Label(NSLocalizedString("ContentView_AddTurnie", comment: "Add turnie button label"), systemImage: "plus")
                        }
                        if bleManager.isConnected {
                            Button(role: .destructive, action: {
                                bleManager.disconnect()
                            }) {
                                Label(String(format: NSLocalizedString("ContentView_Disconnect", comment: "Disconnect device button"), bleManager.deviceName), systemImage: "trash")
                            }
                        }
                    }label: {
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingDeviceList) {
                DeviceListView(isPresented: $showingDeviceList)
            }
            .sheet(isPresented: $showingTextInput) {
                TextInputView(isPresented: $showingTextInput)
            }
            .sheet(isPresented: $showingImageInput) {
                ImageInputView(isPresented: $showingImageInput)
            }
            .sheet(isPresented: $showingPixelInput) {
                PixelArtInputView(isPresented: $showingPixelInput)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(isPresented: $showingSettings)
            }
        }
    }
}

#Preview {
    ContentView()
}
