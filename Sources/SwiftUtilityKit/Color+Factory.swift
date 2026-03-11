import Foundation

#if canImport(CoreGraphics)
import CoreGraphics

/// 通过颜色字符串创建 `ColorRGBA`（支持 HEX/RGB/RGBA）。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `ColorRGBA`。
/// - Throws: `ConversionError.invalidColor`
public func colorRGBA(_ text: String) throws -> ColorRGBA {
    try ColorRGBA.parse(text)
}

/// 通过颜色字符串创建 `CGColor`（支持 HEX/RGB/RGBA）。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `CGColor`。
/// - Throws: `ConversionError.invalidColor`
public func cgColor(_ text: String) throws -> CGColor {
    try ColorRGBA.parse(text).cgColor
}

/// `cgColor(_:)` 的小写别名，便于快速调用。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `CGColor`。
/// - Throws: `ConversionError.invalidColor`
public func cgcolor(_ text: String) throws -> CGColor {
    try cgColor(text)
}

#if canImport(UIKit)
import UIKit

/// 通过颜色字符串创建 `UIColor`（支持 HEX/RGB/RGBA）。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `UIColor`。
/// - Throws: `ConversionError.invalidColor`
public func uiColor(_ text: String) throws -> UIColor {
    try UIColor(colorString: text)
}

/// `uiColor(_:)` 的小写别名，便于快速调用。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `UIColor`。
/// - Throws: `ConversionError.invalidColor`
public func uicolor(_ text: String) throws -> UIColor {
    try uiColor(text)
}
#endif

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
/// 通过颜色字符串创建 `SwiftUI.Color`（支持 HEX/RGB/RGBA）。
///
/// - Parameter text: 颜色字符串。
/// - Returns: 解析后的 `SwiftUI.Color`。
/// - Throws: `ConversionError.invalidColor`
public func swiftUIColor(_ text: String) throws -> Color {
    try ColorRGBA.parse(text).swiftUIColor
}
#endif
#endif
