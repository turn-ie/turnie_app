import SwiftUI

struct PixelArtInputView: View {
    @State private var mosaicArray: [UInt8] = Array(repeating: 255, count: 8 * 8 * 3)
    @State private var selectedColor: Color = .black
    @State private var pickerColor: Color = .red
    @ObservedObject var bleManager: BLEManager
    @Binding var isPresented: Bool

    let paletteColors: [Color] = [
        .black, .white, .red, .green, .blue, .yellow, .orange, .purple
    ]
    
    private func fillAll(with color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)

        for i in stride(from: 0, to: mosaicArray.count, by: 3) {
            mosaicArray[i]     = UInt8(r * 255)
            mosaicArray[i + 1] = UInt8(g * 255)
            mosaicArray[i + 2] = UInt8(b * 255)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Spacer()

                InteractiveMosaicPreview(
                    rgbArray: $mosaicArray,
                    size: 8,
                    selectedColor: $selectedColor
                )
                .frame(width: 260, height: 260)

                // パレット
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ColorPicker("", selection: $pickerColor, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 3)
                            )
                            .clipShape(Circle())
                            .padding(4)
                            .onChange(of: pickerColor) {
                                selectedColor = pickerColor
                            }
                        ForEach(paletteColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .padding(4)
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)


                // Clear
                Button {
                    fillAll(with: selectedColor)
                } label: {
                    Label("塗りつぶす", systemImage: "paintbrush.fill")
                }
                .foregroundColor(.accent)
                
                
                Spacer()
                
                // 保存
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
                    Text("このピクチャを登録")
                        .frame(maxWidth: .infinity)
                }
                .disabled(mosaicArray.isEmpty)
                .buttonStyle(AccentProminentButtonStyle())
            }
            .padding()
            .navigationTitle("ピクセルアート作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
