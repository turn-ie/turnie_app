import UIKit

struct ImageProcessor {
    func processImage(_ image: UIImage?) -> [UInt8]? {
        guard let uiImage = image else { return nil }
        // 1. 正方形にトリミング
        let square = cropCenterSquare(uiImage)
        // 2. 8×8 に縮小
        let small = resizeImage(square, to: CGSize(width: 8, height: 8))
        // 3. RGB配列生成
        return rgbFlatArray(from: small)
    }
    
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
    
    func rgbFlatArray(from image: UIImage) -> [UInt8] {
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

        for y in 0..<height {
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
