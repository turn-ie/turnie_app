import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var bleManager = BLEManager()
    @State private var showingDeviceList = false
    @State private var showingTextInput = false
    @State private var showingImageInput = false
    @State private var showingPixelInput = false
    
    var body: some View {
        
        let gapSize = CGFloat(5)
        let columns = [
            GridItem(.flexible(), spacing: gapSize),
            GridItem(.flexible(), spacing: gapSize)
        ]
        
        NavigationView {
            VStack() {
                if bleManager.isAutoConnecting {
                    // 過去に繋いだデバイスがあれば自動で接続する
                    VStack {
                        Spacer()
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("Reconnecting to \(bleManager.deviceName)")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if bleManager.isConnected {
                        let iconSize = CGFloat(20)
                        LazyVGrid(columns: columns, spacing: gapSize) {
                            Button(action: {showingTextInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "textformat")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text("テキスト")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            Button(action: {showingImageInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "photo")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text("写真")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                            Button(action: {showingPixelInput = true}) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: iconSize))
                                    Spacer()
                                    Text("つくる")
                                }
                            }
                            .buttonStyle(DashboardButtonStyle())
                        }
                        
                        //                        Section(header: Text("ピクチャをおくる").font(.caption)) {
                        //                            HStack(spacing: 20) {
                        //                                Button(action: {
                        //                                    showingTextInput = true
                        //                                }) {
                        //                                    Label("テキスト", systemImage: "textformat")
                        //                                }
                        //                                .buttonStyle(AccentProminentButtonStyle())
                        //
                        //                                Button(action: {
                        //                                    showingImageInput = true
                        //                                }) {
                        //                                    Label("写真", systemImage: "photo")
                        //                                }
                        //                                .buttonStyle(AccentProminentButtonStyle())
                        //
                        //                                Button(action: {
                        //                                    showingPixelInput = true
                        //                                }) {
                        //                                    Label("つくる", systemImage: "paintpalette.fill")
                        //                                }
                        //                                .buttonStyle(AccentProminentButtonStyle())
                        //                            }
                        //                        }
                        // ESPがdata.jsonに持っているデータを取得。したい。
                        //                        Section(header: Text("これまでに送ったピクチャ").font(.caption)){
                        //                            Text(bleManager.receivedData.isEmpty ? "まだデータはありません" : bleManager.receivedData)
                        //                                .font(.system(size: 14, design: .monospaced))
                        //                                .padding()
                        //                                .frame(maxWidth: .infinity, alignment: .leading)
                        //                                .background(Color(.systemGray6))
                        //                                .cornerRadius(8)
                        //
                        //                            Button(action:{
                        //                                bleManager.requestDataJson()
                        //                            }) {
                        //                                Text("データを取得")
                        //                                    .frame(maxWidth: .infinity)
                        //                            }
                        //                            .buttonStyle(AccentProminentButtonStyle())
                        //                        }
                } else {
                    VStack(spacing: 20) {
                        if bleManager.deviceName != "No Device" {
                            Spacer()
                            Text("No devices found")
                                .foregroundColor(.secondary)
                            Text("Last connected: \(bleManager.deviceName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
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
