import SwiftUI
import UIKit
import AVFoundation

struct ImageInputView: View {
    @State private var showingCamera = false
    @State private var showingLibrary = false
    @State private var mosaicArray: [UInt8] = []
    @State private var debugText: String = "まだ写真がありません"
    @ObservedObject var bleManager: BLEManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                if !mosaicArray.isEmpty {
                    VStack {
                        MosaicPreview(rgbArray: mosaicArray, size: 8)
                            .frame(width: 250, height: 250)
                    }
                } else {
                    Text(debugText)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack() {
                    Button(action: {
                        let text = mosaicArray
                        guard !text.isEmpty else { return }
//                        let redRGB: [UInt8] = Array(repeating: 0, count: 8 * 8 * 3).enumerated().map { index, _ in
//                            switch index % 3 {
//                            case 0: return 255  // R
//                            default: return 0   // G, B
//                            }
//                        }
                        let json: [String: Any] = [
                            "id": "p002",
                            "flag": "image",
                            "rgb": text
//                            "rgb": redRGB
                        ]
                        bleManager.sendJSON(json)
                        mosaicArray = []
                        isPresented = false
                    }) {
                        Text("このピクチャを登録")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(mosaicArray.isEmpty)
                    .buttonStyle(AccentProminentButtonStyle())
                    
                    HStack() {
                        Button(action: {
                            showingLibrary = true
                        }) {
                            Label("写真", systemImage: "photo")
                        }
                        .buttonStyle(AccentProminentButtonStyle())
                        
                        Button(action: {
                            showingCamera = true
                        }) {
                            Label("カメラ", systemImage: "camera")
                        }
                        .buttonStyle(AccentProminentButtonStyle())
                    }
                }
                .padding()
                .sheet(isPresented: $showingCamera) {
                    ImagePicker(sourceType: .camera) { image in
                        processImage(image)
                    }
                }
                .sheet(isPresented: $showingLibrary) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        processImage(image)
                    }
                }
            }
            .padding()
            .navigationTitle("写真をおくる")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .presentationDetents([.large])
        }
    }

    // MARK: - 共通画像処理
    func processImage(_ image: UIImage?) {
        guard let uiImage = image else {
            debugText = "画像が取得できませんでした"
            return
        }
        // 1. 正方形にトリミング
        let square = cropCenterSquare(uiImage)
        // 2. 8×8 に縮小
        let small = resizeImage(square, to: CGSize(width: 8, height: 8))
        // 3. RGB配列生成
        let flat = rgbFlatArray(from: small)
        mosaicArray = flat
        debugText = "生成完了: \(flat.count) バイト"
    }
    
    // MARK: - Image processing helpers

    func cropCenterSquare(_ image: UIImage) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let length = min(w, h)
        let originX = (w - length) / 2.0
        let originY = (h - length) / 2.0
        let cropRect = CGRect(x: originX, y: originY, width: length, height: length).integral
        guard let croppedCg = cg.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: croppedCg, scale: image.scale, orientation: image.imageOrientation)
    }

    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

//    func rgbFlatArray(from image: UIImage) -> [UInt8] {
//        guard let cg = image.cgImage else { return [] }
//        let width = cg.width
//        let height = cg.height
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let totalBytes = height * bytesPerRow
//
//        var pixelData = [UInt8](repeating: 0, count: totalBytes)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        guard let context = CGContext(
//            data: &pixelData,
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: bytesPerRow,
//            space: colorSpace,
////            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
//        ) else { return [] }
//
//        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//        var flatRGB: [UInt8] = []
//        flatRGB.reserveCapacity(width * height * 3)
//
//        for y in 0..<height {
//            for x in 0..<width {
//                let idx = y * bytesPerRow + x * bytesPerPixel
//                let r = pixelData[idx]
//                let g = pixelData[idx + 1]
//                let b = pixelData[idx + 2]
//                flatRGB.append(r)
//                flatRGB.append(g)
//                flatRGB.append(b)
//            }
//        }
//
//        return flatRGB
//    }
    func rgbFlatArray(from image: UIImage) -> [UInt8] {
        // 🔸 必ず 8x8 にリサイズ
        let targetSize = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(targetSize)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cg = resizedImage?.cgImage else { return [] }

        let width = cg.width
        let height = cg.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow

        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // ✅ ARGB形式で安全に取得（Alphaを無視）
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return [] }

        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        var flatRGB: [UInt8] = []
        flatRGB.reserveCapacity(width * height * 3)

        // 🔸 CoreGraphicsは下→上の順で描画されることが多いため、反転して走査
//        for y in (0..<height).reversed() {
        for y in 0..<height{
            for x in 0..<width {
                let idx = y * bytesPerRow + x * bytesPerPixel
                let r = pixelData[idx]
                let g = pixelData[idx + 1]
                let b = pixelData[idx + 2]
                flatRGB.append(r)
                flatRGB.append(g)
                flatRGB.append(b)
            }
        }

        return flatRGB
    }

}


// MARK: - モザイクプレビュー
/// RGB フラット配列（r,g,b,...）を 8×8 のモザイクとして表示
struct MosaicPreview: View {
    let rgbArray: [UInt8]
    let size: Int // 8

    var body: some View {
        GeometryReader { geo in
            let cell = geo.size.width / CGFloat(size)
            Canvas { context, _ in
                for y in 0..<size {
                    for x in 0..<size {
                        let idx = (y * size + x) * 3
                        if idx + 2 < rgbArray.count {
                            let r = rgbArray[idx]
                            let g = rgbArray[idx + 1]
                            let b = rgbArray[idx + 2]
                            let color = Color(
                                red: Double(r) / 255.0,
                                green: Double(g) / 255.0,
                                blue: Double(b) / 255.0
                            )
                            let rect = CGRect(
                                x: CGFloat(x) * cell,
                                y: CGFloat(y) * cell,
                                width: cell,
                                height: cell
                            )
                            context.fill(Path(rect), with: .color(color))
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


// MARK: - ImagePicker と UIImage.fixOrientation（前と同じ）

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .camera
    var completion: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var image = info[.originalImage] as? UIImage
            if let img = image {
                image = img.fixOrientation()
            }
            parent.completion(image)
            picker.dismiss(animated: true)
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}
