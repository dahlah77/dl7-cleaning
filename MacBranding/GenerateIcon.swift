import AppKit
import Foundation

let output = CommandLine.arguments[1]
let size = 1024
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
    isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
) else { fatalError("Cannot allocate icon") }

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
let frame = NSRect(x: 0, y: 0, width: size, height: size)
NSColor.clear.setFill()
frame.fill()
let background = NSBezierPath(roundedRect: frame.insetBy(dx: 24, dy: 24), xRadius: 225, yRadius: 225)
let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.01, green: 0.05, blue: 0.10, alpha: 1),
    NSColor(calibratedRed: 0.02, green: 0.17, blue: 0.23, alpha: 1)
])!
gradient.draw(in: background, angle: 135)

let border = NSBezierPath(roundedRect: frame.insetBy(dx: 39, dy: 39), xRadius: 212, yRadius: 212)
border.lineWidth = 5
NSColor(calibratedRed: 0.27, green: 0.92, blue: 0.97, alpha: 0.42).setStroke()
border.stroke()

let text = "D7" as NSString
let font = NSFont.systemFont(ofSize: 428, weight: .black)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor(calibratedRed: 0.30, green: 0.93, blue: 0.99, alpha: 1)
]
let dimensions = text.size(withAttributes: attributes)
text.draw(at: NSPoint(x: (CGFloat(size) - dimensions.width)/2, y: (CGFloat(size) - dimensions.height)/2 + 12), withAttributes: attributes)

func sparkle(x: CGFloat, y: CGFloat, radius: CGFloat) {
    let shape = NSBezierPath()
    shape.move(to: NSPoint(x:x-radius, y:y))
    shape.curve(to: NSPoint(x:x+radius, y:y), controlPoint1:NSPoint(x:x, y:y+radius*0.4), controlPoint2:NSPoint(x:x, y:y+radius*0.4))
    shape.move(to: NSPoint(x:x, y:y-radius))
    shape.line(to: NSPoint(x:x, y:y+radius))
    shape.lineWidth = 10
    shape.lineCapStyle = .round
    NSColor.white.setStroke()
    shape.stroke()
}
sparkle(x: 765, y: 760, radius: 73)
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output))
