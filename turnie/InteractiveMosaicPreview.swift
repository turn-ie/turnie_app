import SwiftUI

struct InteractiveMosaicPreview: View {
    @Binding var rgbArray: [UInt8]
    let size: Int
    @Binding var selectedColor: Color

    var body: some View {
        GeometryReader { geo in
            let cell = geo.size.width / CGFloat(size)

            ZStack {
                // --- ピクセル描画 ---
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

                // --- グリッド線描画 ---
                Canvas { context, sizeInfo in
                    let w = sizeInfo.width
                    let h = sizeInfo.height
                    let gridColor = Color(.sRGB, white: 0.1, opacity: 0.3)

                    // 縦線
                    for i in 0...size {
                        let x = CGFloat(i) * cell
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: h))
                        context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                    }

                    // 横線
                    for i in 0...size {
                        let y = CGFloat(i) * cell
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                        context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = Int(value.location.x / cell)
                        let y = Int(value.location.y / cell)
                        changePixel(x: x, y: y)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func changePixel(x: Int, y: Int) {
        guard x >= 0 && x < size, y >= 0 && y < size else { return }

        let idx = (y * size + x) * 3

        let uiColor = UIColor(selectedColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)

        rgbArray[idx]     = UInt8(r * 255)
        rgbArray[idx + 1] = UInt8(g * 255)
        rgbArray[idx + 2] = UInt8(b * 255)
    }
}
