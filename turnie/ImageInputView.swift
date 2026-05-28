import SwiftUI
import UIKit
import AVFoundation

struct ImageInputView: View {
    @State private var showingCamera = false
    @State private var showingLibrary = false
    @State private var mosaicArray: [UInt8] = []
    @EnvironmentObject var bleManager: BLEManager
    @State private var debugText: String = NSLocalizedString("ImageInput_NoPhotoAvailable", comment: "Message when no photo is available")
    @Binding var isPresented: Bool
    
    private let processor = ImageProcessor()

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
                        let json: [String: Any] = [
                            "id": "p002",
                            "flag": "image",
                            "rgb": text
                        ]
                        bleManager.sendJSON(json)
                        mosaicArray = []
                        isPresented = false
                    }) {
                        Text(NSLocalizedString("Common_RegisterPicture", comment: "Register picture button"))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(mosaicArray.isEmpty)
                    .buttonStyle(AccentProminentButtonStyle())
                    
                    HStack() {
                        Button(action: {
                            showingLibrary = true
                        }) {
                            Label(NSLocalizedString("ContentView_PhotoButton", comment: "Photo input button"), systemImage: "photo")
                        }
                        .buttonStyle(AccentProminentButtonStyle())
                        
                        Button(action: {
                            showingCamera = true
                        }) {
                            Label(NSLocalizedString("ImageInput_CameraButton", comment: "Camera button"), systemImage: "camera")
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
            .navigationTitle(NSLocalizedString("ImageInput_NavigationTitle", comment: "Image input view title"))
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
        guard let flat = processor.processImage(image) else {
            debugText = NSLocalizedString("ImageInput_ImageFetchFailed", comment: "Error message when image fetching fails")
            return
        }
        mosaicArray = flat
        debugText = String(format: NSLocalizedString("ImageInput_GenerationComplete", comment: "Image generation complete message"), flat.count)
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
