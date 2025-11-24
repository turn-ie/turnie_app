import CoreBluetooth
import Combine

struct DiscoveredDevice: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let rssi: Int
    var name: String {
        peripheral.name ?? "Unknown Device"
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var isAutoConnecting = false
    @Published var deviceName = "No Device"
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var hasPreviousDevice = false
    @Published var receivedData: String = ""
    
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    func reconnectToLastDevice() {
        guard hasPreviousDevice else {
            print("No previous device to reconnect")
            return
        }

        print("Manual reconnect triggered")
        
        shouldAutoConnect = true
        isAutoConnecting = false
        isScanning = false

        startAutoConnect()
    }
    
    private let lastConnectedUUIDKey = "lastConnectedDeviceUUID"
    private var lastConnectedUUID: UUID? {
        get {
            if let uuidString = UserDefaults.standard.string(forKey: lastConnectedUUIDKey) {
                return UUID(uuidString: uuidString)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue?.uuidString, forKey: lastConnectedUUIDKey)
        }
    }
    
    private let lastConnectedNameKey = "lastConnectedDeviceName"
    var lastConnectedName: String? {
        get {
            UserDefaults.standard.string(forKey: lastConnectedNameKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastConnectedNameKey)
        }
    }

    let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-1234567890ab")
    let rxCharacteristicUUID = CBUUID(string: "abcd1234-5678-90ab-cdef-1234567890ab")
    let txCharacteristicUUID = CBUUID(string: "abcd1234-5678-90ab-cdef-1234567890ac")
    
    private var shouldAutoConnect = true

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        if let name = lastConnectedName {
            deviceName = name
        }
        
        hasPreviousDevice = (lastConnectedUUID != nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is ready")
            if shouldAutoConnect, hasPreviousDevice {
                startAutoConnect()
            }
        } else {
            print("Bluetooth is not available")
        }
    }
    
    // 自動接続開始
    private func startAutoConnect() {
        guard let uuid = lastConnectedUUID else { return }
        
        isAutoConnecting = true
        
        print("Attempting auto-connect to last device:", lastConnectedName ?? "Unknown")
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        
        if let peripheral = peripherals.first {
            targetPeripheral = peripheral
            targetPeripheral?.delegate = self
            deviceName = peripheral.name ?? lastConnectedName ?? "Unknown"
            centralManager.connect(peripheral)
        } else {
            print("Last device not found, scanning...")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if self.isAutoConnecting && !self.isConnected {
                        print("Auto-connect timed out")
                        self.centralManager.stopScan()
                        self.isAutoConnecting = false
                    }
                }
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on")
            return
        }
        
        discoveredDevices.removeAll()
        isScanning = true
        shouldAutoConnect = false
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        print("Started scanning for ESP32...")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        print("Stopped scanning")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if shouldAutoConnect, let lastUUID = lastConnectedUUID,
           peripheral.identifier == lastUUID {
            print("Found last connected device:", peripheral.name ?? "Unknown")
            stopScanning()
            connect(to: peripheral)
            return
        }
        if isScanning {
            if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
                let device = DiscoveredDevice(peripheral: peripheral, rssi: RSSI.intValue)
                discoveredDevices.append(device)
                print("Found device:", device.name, "RSSI:", RSSI)
            }
        }
    }
    
    func connect(to device: DiscoveredDevice) {
        connect(to: device.peripheral)
    }
    
    private func connect(to peripheral: CBPeripheral) {
        stopScanning()
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        deviceName = peripheral.name ?? "Unknown"
        centralManager.connect(peripheral)
        print("Connecting to:", deviceName)
    }
    
    func disconnect() {
        if let peripheral = targetPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to", peripheral.name ?? "device")
        isConnected = true
        isAutoConnecting = false
        deviceName = peripheral.name ?? "Unknown"
        
        // 接続情報を保存
        lastConnectedUUID = peripheral.identifier
        lastConnectedName = deviceName
        
        peripheral.discoverServices([serviceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services:", error.localizedDescription)
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([rxCharacteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics:", error.localizedDescription)
            return
        }
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == rxCharacteristicUUID {
                writeCharacteristic = characteristic
                print("Ready to send JSON")
            } else if characteristic.uuid == txCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to TX characteristic (for receiving data.json)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error receiving data:", error!.localizedDescription)
            return
        }
        guard let data = characteristic.value,
              let text = String(data: data, encoding: .utf8) else { return }

        DispatchQueue.main.async {
            self.receivedData += text + "\n"
        }
    }
    
    func requestDataJson() {
        guard let writeCharacteristic = writeCharacteristic,
              let peripheral = targetPeripheral else {
            print("Not connected or write characteristic not ready")
            return
        }
        if let data = "GET_DATA".data(using: .utf8) {
            peripheral.writeValue(data, for: writeCharacteristic, type: .withResponse)
            print("Requested /data.json from ESP32")
            receivedData = "" // 前回分をクリア
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect:", error?.localizedDescription ?? "Unknown error")
        isConnected = false
        isAutoConnecting = false
        deviceName = lastConnectedName ?? "No Device"
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from", peripheral.name ?? "device")
        isConnected = false
        isAutoConnecting = false
        writeCharacteristic = nil
    }

//    func sendJSON(_ json: [String: Any]) {
//        guard let writeCharacteristic = writeCharacteristic,
//              let peripheral = targetPeripheral,
//              let data = try? JSONSerialization.data(withJSONObject: json) else {
//            print("Cannot send JSON: not ready")
//            return
//        }
//
//        peripheral.writeValue(data, for: writeCharacteristic, type: .withResponse)
//        print("Sent JSON to ESP32")
//    }
    /// JSONデータを分割して送信する（テキスト・画像共通）
    func sendJSON(_ json: [String: Any]) {
        guard let writeCharacteristic = writeCharacteristic,
              let peripheral = targetPeripheral else {
            print("⚠️ Not connected")
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let jsonString = String(data: data, encoding: .utf8) else {
            print("⚠️ Failed to encode JSON")
            return
        }

        let chunks = jsonString.chunked(into: 100)
        print("📤 Sending JSON in \(chunks.count) chunks")

        for chunk in chunks {
            if let chunkData = chunk.data(using: .utf8) {
                peripheral.writeValue(chunkData, for: writeCharacteristic, type: .withResponse)
                usleep(30_000) // 30ms待機で安定化
            }
        }

        print("✅ JSON sent successfully")
    }
}

extension String {
    func chunked(into size: Int) -> [String] {
        stride(from: 0, to: count, by: size).map { i in
            let start = index(startIndex, offsetBy: i)
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}
