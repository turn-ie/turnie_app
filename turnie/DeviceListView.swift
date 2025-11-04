import SwiftUI

struct DeviceListView: View {
    @ObservedObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if bleManager.isScanning && bleManager.discoveredDevices.isEmpty {
                    Spacer()
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("Scanning for devices...")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                if bleManager.discoveredDevices.isEmpty {
                    Spacer()
                    Text("No devices found")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(bleManager.discoveredDevices) { device in
                        Button(action: {
                            bleManager.connect(to: device)
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.name)
                                        .font(.headline)
                                    Text("RSSI: \(device.rssi) dBm")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .background(.pink)
                }
            }
            .navigationTitle("Select Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        bleManager.stopScanning()
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onDisappear {
            bleManager.stopScanning()
        }
    }
}
