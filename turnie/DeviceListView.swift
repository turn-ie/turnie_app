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
                        Text(NSLocalizedString("DeviceList_Scanning", comment: "Scanning for devices message"))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                if bleManager.discoveredDevices.isEmpty {
                    Spacer()
                    Text(NSLocalizedString("DeviceList_NoDevicesFound", comment: "No devices found message"))
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
                                    Text(String(format: NSLocalizedString("DeviceList_RSSI", comment: "Device RSSI value"), device.rssi))
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
            .navigationTitle(NSLocalizedString("DeviceList_SelectDevice", comment: "Device list navigation title"))
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
