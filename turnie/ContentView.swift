import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var bleManager = BLEManager()
    @State private var showingDeviceList = false
    @State private var showingTextInput = false
    @State private var showingImageInput = false
    @State private var showingPixelInput = false
    @State private var mosaicArray: [UInt8] = Array(repeating: 255, count: 8 * 8 * 3)
    
    var body: some View {
        
        let gapSize = CGFloat(5)
        let columns = [
            GridItem(.flexible(), spacing: gapSize),
            GridItem(.flexible(), spacing: gapSize)
        ]
        
        NavigationView {
            VStack() {
//                if bleManager.isAutoConnecting {
//                    // 過去に繋いだデバイスがあれば自動で接続する
//                    VStack {
//                        Spacer()
//                        ProgressView()
//                            .padding(.trailing, 8)
//                        Text("Reconnecting to \(bleManager.deviceName)")
//                            .foregroundColor(.secondary)
//                        Spacer()
//                    }
//                } else if bleManager.isConnected {
                        let iconSize = CGFloat(20)
                        LazyVGrid(columns: columns, spacing: gapSize) {
                            Button(action:{bleManager.reconnectToLastDevice()}){
                                ZStack(alignment: .bottomTrailing) {
                                    VStack(alignment: .leading) {
                                        if bleManager.isAutoConnecting {
                                            HStack{
                                                ProgressView()
//                                                    .padding(.trailing, 8)
                                                    .scaleEffect(x: 0.75, y: 0.75, anchor: .center)
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                                Text(
                                                    bleManager.isAutoConnecting
                                                    ? "Connecting"
                                                    : (bleManager.deviceName.isEmpty ? "No Device" : bleManager.deviceName)
                                                )
                                                .font(.caption)
                                            }
                                        } else {
                                            if bleManager.isConnected {
                                                Text("Connected")
                                                    .font(.caption)
                                            } else{
                                                VStack(alignment: .leading) {
                                                    Text("Disconnected")
                                                        .font(.caption)
                                                    Text("Tap to Reconnect")
                                                        .font(.caption2)
                                                }
                                            }
                                        }
                                        Spacer()
                                        Text(bleManager.deviceName.isEmpty ? "No Device" : bleManager.deviceName)
                                        
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .padding(20)
                                    .foregroundColor(Color(.white))
                                    
                                    //                                MosaicPreview(rgbArray: mosaicArray, size: 8)
                                    //                                        .frame(width: 125, height: 125)
                                    //                                        .rotationEffect(.degrees(5))
                                    //                                        .offset(x: 5, y: 15)
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
                                    Text("テキスト")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                            
                            Button(action: {showingImageInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "photo")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text("写真")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                            
                            Button(action: {showingPixelInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text("つくる")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            .disabled(!bleManager.isConnected)
                        }
//                } else {
//                    VStack(spacing: 20) {
//                        if bleManager.deviceName != "No Device" {
//                            Spacer()
//                            Text("No devices found")
//                                .foregroundColor(.secondary)
//                            Text("Last connected: \(bleManager.deviceName)")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            Spacer()
//                        }
//                    }
//                }
                Spacer()
            }
            .padding()
            .navigationTitle("turnie")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingDeviceList = true
                            bleManager.startScanning()
                        }) {
                            Label("Add turnie", systemImage: "plus")
                        }
                        if bleManager.isConnected {
                            Button(role: .destructive, action: {
                                bleManager.disconnect()
                            }) {
                                Label("Disconnect \(bleManager.deviceName)", systemImage: "trash")
                            }
                        }
                    }label: {
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingDeviceList) {
                DeviceListView(bleManager: bleManager, isPresented: $showingDeviceList)
            }
            .sheet(isPresented: $showingTextInput) {
                TextInputView(bleManager: bleManager, isPresented: $showingTextInput)
            }
            .sheet(isPresented: $showingImageInput) {
                ImageInputView(bleManager: bleManager, isPresented: $showingImageInput)
            }
            .sheet(isPresented: $showingPixelInput) {
                PixelArtInputView(bleManager: bleManager, isPresented: $showingPixelInput)
            }
        }
    }
}

#Preview {
    ContentView()
}
