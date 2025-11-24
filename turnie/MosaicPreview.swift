import SwiftUI

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
