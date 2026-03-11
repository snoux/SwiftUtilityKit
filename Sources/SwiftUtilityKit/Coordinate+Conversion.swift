import Foundation

#if canImport(CoreLocation)
import CoreLocation

/// 坐标排列顺序。
public enum CoordinateOrder: String, CaseIterable, Sendable {
    /// `latitude,longitude`
    case latitudeLongitude
    /// `longitude,latitude`
    case longitudeLatitude
}

/// 坐标转换扩展。
public extension CLLocationCoordinate2D {
    /// 坐标是否有效（范围 + CoreLocation 校验）。
    var isValidCoordinate: Bool {
        CLLocationCoordinate2DIsValid(self)
            && (-90...90).contains(latitude)
            && (-180...180).contains(longitude)
    }

    /// 从字符串解析坐标。
    ///
    /// - Parameters:
    ///   - text: 坐标文本，默认格式如 `31.2304,121.4737`
    ///   - separator: 分隔符，默认 `,`
    ///   - order: 字段顺序，默认 `latitude,longitude`
    /// - Throws: `ConversionError.invalidCoordinate`
    static func parse(
        _ text: String,
        separator: Character = ",",
        order: CoordinateOrder = .latitudeLongitude
    ) throws -> CLLocationCoordinate2D {
        let parts = text
            .split(separator: separator, omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        guard parts.count == 2,
              let first = Double(parts[0]),
              let second = Double(parts[1]) else {
            throw ConversionError.invalidCoordinate(text)
        }

        let coordinate: CLLocationCoordinate2D
        switch order {
        case .latitudeLongitude:
            coordinate = CLLocationCoordinate2D(latitude: first, longitude: second)
        case .longitudeLatitude:
            coordinate = CLLocationCoordinate2D(latitude: second, longitude: first)
        }

        guard coordinate.isValidCoordinate else {
            throw ConversionError.invalidCoordinate(text)
        }
        return coordinate
    }

    /// 从元组创建坐标。
    ///
    /// - Throws: `ConversionError.invalidCoordinate`
    static func make(
        _ tuple: (Double, Double),
        order: CoordinateOrder = .latitudeLongitude
    ) throws -> CLLocationCoordinate2D {
        let coordinate: CLLocationCoordinate2D
        switch order {
        case .latitudeLongitude:
            coordinate = CLLocationCoordinate2D(latitude: tuple.0, longitude: tuple.1)
        case .longitudeLatitude:
            coordinate = CLLocationCoordinate2D(latitude: tuple.1, longitude: tuple.0)
        }
        guard coordinate.isValidCoordinate else {
            throw ConversionError.invalidCoordinate("\(tuple.0),\(tuple.1)")
        }
        return coordinate
    }

    /// 从字典创建坐标。
    ///
    /// 支持键：
    /// - `latitude` / `longitude`
    /// - `lat` / `lng`
    /// - `lat` / `lon`
    ///
    /// - Parameter dictionary: 坐标字典。
    /// - Returns: 解析后的坐标。
    /// - Throws: `ConversionError.invalidCoordinate`
    static func make(from dictionary: [String: Double]) throws -> CLLocationCoordinate2D {
        let lat = dictionary["latitude"] ?? dictionary["lat"]
        let lon = dictionary["longitude"] ?? dictionary["lng"] ?? dictionary["lon"]
        guard let latitude = lat, let longitude = lon else {
            throw ConversionError.invalidCoordinate(String(describing: dictionary))
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        guard coordinate.isValidCoordinate else {
            throw ConversionError.invalidCoordinate(String(describing: dictionary))
        }
        return coordinate
    }

    /// 坐标转字符串。
    func string(
        order: CoordinateOrder = .latitudeLongitude,
        separator: String = ",",
        fractionDigits: Int = 6
    ) -> String {
        let first: Double
        let second: Double
        switch order {
        case .latitudeLongitude:
            first = latitude
            second = longitude
        case .longitudeLatitude:
            first = longitude
            second = latitude
        }
        return "\(format(first, fractionDigits: fractionDigits))\(separator)\(format(second, fractionDigits: fractionDigits))"
    }

    /// 坐标转元组。
    ///
    /// - Parameter order: 输出字段顺序。
    /// - Returns: 坐标元组。
    func tuple(order: CoordinateOrder = .latitudeLongitude) -> (Double, Double) {
        switch order {
        case .latitudeLongitude:
            return (latitude, longitude)
        case .longitudeLatitude:
            return (longitude, latitude)
        }
    }

    /// 坐标转字典（固定键 `latitude/longitude`）。
    func dictionary() -> [String: Double] {
        ["latitude": latitude, "longitude": longitude]
    }

    /// 交换经纬度（用于字段顺序纠正）。
    func swappedLatLon() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: longitude, longitude: latitude)
    }

    /// 数值格式化（用于坐标字符串输出）。
    ///
    /// - Parameters:
    ///   - value: 原始数值。
    ///   - fractionDigits: 最大小数位。
    /// - Returns: 格式化后的字符串。
    private func format(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(0, fractionDigits)
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

public extension String {
    /// 字符串转坐标。
    ///
    /// - Throws: `ConversionError.invalidCoordinate`
    func coordinate(
        separator: Character = ",",
        order: CoordinateOrder = .latitudeLongitude
    ) throws -> CLLocationCoordinate2D {
        try CLLocationCoordinate2D.parse(self, separator: separator, order: order)
    }
}
#endif
