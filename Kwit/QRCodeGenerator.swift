import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum QRCodeGenerator {

    static func generateImage(from string: String, size: CGFloat = 600) -> UIImage? {
        guard !string.isEmpty, let data = string.data(using: .utf8) else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "H"

        guard let ciImage = filter.outputImage else { return nil }

        let scaleX = size / ciImage.extent.width
        let scaleY = size / ciImage.extent.height
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    static func svgTempURL(from string: String) -> URL? {
        guard let svg = generateSVG(from: string) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("qrcode.svg")
        try? svg.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Private

    private static func generateSVG(from string: String) -> String? {
        guard !string.isEmpty, let data = string.data(using: .utf8) else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "H"

        guard let ciImage = filter.outputImage else { return nil }

        let context = CIContext()
        let extent = ciImage.extent
        let width = Int(extent.width)
        let height = Int(extent.height)

        guard let cgImage = context.createCGImage(ciImage, from: extent) else { return nil }

        var pixels = [UInt8](repeating: 0, count: width * height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let bitmapCtx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }

        bitmapCtx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let moduleSize = 10
        let svgSize = width * moduleSize
        var rects = ""

        for y in 0..<height {
            for x in 0..<width where pixels[y * width + x] < 128 {
                rects += "<rect x=\"\(x * moduleSize)\" y=\"\(y * moduleSize)\" width=\"\(moduleSize)\" height=\"\(moduleSize)\"/>"
            }
        }

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(svgSize) \(svgSize)" width="\(svgSize)" height="\(svgSize)">
        <rect width="\(svgSize)" height="\(svgSize)" fill="white"/>
        <g fill="black">\(rects)</g>
        </svg>
        """
    }
}
