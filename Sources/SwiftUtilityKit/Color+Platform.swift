import Foundation
#if canImport(CoreGraphics)
import CoreGraphics

public extension ColorRGBA {
    /// 使用 0...1 范围的浮点通道创建颜色。
    ///
    /// - Parameters:
    ///   - red: 红色通道（0...1）。
    ///   - green: 绿色通道（0...1）。
    ///   - blue: 蓝色通道（0...1）。
    ///   - alpha: 透明度（0...1）。
    /// - Throws: `ConversionError.invalidColor`
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) throws {
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        let a = Int((alpha * 255).rounded())
        try self.init(red: r, green: g, blue: b, alpha: a)
    }

    /// 快速通过十六进制字符串创建颜色。
    ///
    /// - Parameter hex: HEX 颜色字符串。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    static func fromHex(_ hex: String) throws -> ColorRGBA {
        try parse(hex)
    }

    /// 快速通过 RGB/RGBA 字符串创建颜色。
    ///
    /// 例如：`rgb(255,102,0)`、`rgba(255,102,0,0.5)`。
    ///
    /// - Parameter text: RGB/RGBA 颜色字符串。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    static func fromRGBString(_ text: String) throws -> ColorRGBA {
        try parse(text)
    }

    /// 转为 `CGColor`。
    var cgColor: CGColor {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [
            CGFloat(red) / 255,
            CGFloat(green) / 255,
            CGFloat(blue) / 255,
            CGFloat(alpha) / 255
        ]
        return CGColor(colorSpace: colorSpace, components: components)
            ?? CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components)!
    }

    /// 从 `CGColor` 创建 `ColorRGBA`。
    ///
    /// - Parameter cgColor: 输入 `CGColor`。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    init(cgColor: CGColor) throws {
        let space = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        guard let converted = cgColor.converted(to: space, intent: .defaultIntent, options: nil) else {
            throw ConversionError.invalidColor("cgColor")
        }
        guard let components = converted.components else {
            throw ConversionError.invalidColor("cgColor")
        }

        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat

        if components.count >= 4 {
            r = components[0]
            g = components[1]
            b = components[2]
            a = components[3]
        } else if components.count == 2 {
            r = components[0]
            g = components[0]
            b = components[0]
            a = components[1]
        } else {
            throw ConversionError.invalidColor("cgColor")
        }

        try self.init(red: r, green: g, blue: b, alpha: a)
    }
}

#if canImport(UIKit)
import UIKit

public extension ColorRGBA {
    /// 转为 `UIColor`。
    var uiColor: UIColor {
        UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }

    /// 从 `UIColor` 创建 `ColorRGBA`。
    ///
    /// - Parameter uiColor: 输入 `UIColor`。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    init(uiColor: UIColor) throws {
        var redValue: CGFloat = 0
        var greenValue: CGFloat = 0
        var blueValue: CGFloat = 0
        var alphaValue: CGFloat = 0

        if uiColor.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: &alphaValue) {
            try self.init(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
        } else {
            try self.init(cgColor: uiColor.cgColor)
        }
    }
}

public extension UIColor {
    /// 从 `ColorRGBA` 创建 `UIColor`。
    convenience init(_ color: ColorRGBA) {
        self.init(
            red: CGFloat(color.red) / 255,
            green: CGFloat(color.green) / 255,
            blue: CGFloat(color.blue) / 255,
            alpha: CGFloat(color.alpha) / 255
        )
    }

    /// 转为 `ColorRGBA`。
    ///
    /// - Throws: `ConversionError.invalidColor`
    func toColorRGBA() throws -> ColorRGBA {
        try ColorRGBA(uiColor: self)
    }

    /// 通过 HEX 字符串创建 `UIColor`。
    ///
    /// - Throws: `ConversionError.invalidColor`
    convenience init(hex: String) throws {
        self.init(try ColorRGBA.fromHex(hex))
    }

    /// 通过 RGB/RGBA 字符串创建 `UIColor`。
    ///
    /// - Throws: `ConversionError.invalidColor`
    convenience init(rgbString: String) throws {
        self.init(try ColorRGBA.fromRGBString(rgbString))
    }

    /// 通过颜色字符串创建 `UIColor`（支持 HEX/RGB/RGBA）。
    ///
    /// - Throws: `ConversionError.invalidColor`
    convenience init(colorString: String) throws {
        self.init(try ColorRGBA.parse(colorString))
    }
}
#endif

public extension String {
    /// 颜色字符串转 `CGColor`（支持 HEX/RGB/RGBA）。
    ///
    /// - Throws: `ConversionError.invalidColor`
    func toCGColor() throws -> CGColor {
        try ColorRGBA.parse(self).cgColor
    }
}

#if canImport(SwiftUI)
import SwiftUI

public extension ColorRGBA {
    /// 转为 `SwiftUI.Color`。
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var swiftUIColor: Color {
        Color(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

#if canImport(UIKit)
public extension String {
    /// 颜色字符串转 `UIColor`（支持 HEX/RGB/RGBA）。
    ///
    /// - Throws: `ConversionError.invalidColor`
    func toUIColor() throws -> UIColor {
        try UIColor(colorString: self)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Color {
    /// 转为 `ColorRGBA`（iOS/tvOS/watchOS 通过 UIKit 桥接）。
    ///
    /// - Throws: `ConversionError.invalidColor`
    func toColorRGBA() throws -> ColorRGBA {
        try UIColor(self).toColorRGBA()
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension String {
    /// 颜色字符串转 `SwiftUI.Color`（支持 HEX/RGB/RGBA）。
    ///
    /// - Throws: `ConversionError.invalidColor`
    func toSwiftUIColor() throws -> Color {
        try ColorRGBA.parse(self).swiftUIColor
    }
}
#endif
#endif
#endif
