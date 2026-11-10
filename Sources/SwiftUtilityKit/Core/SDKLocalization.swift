import Foundation

/// 从 SDK 自己的资源包中选择文案，不依赖宿主 App 支持的语言。
struct SDKLocalization {
    private static let fallbackLanguage = "en"
    private let bundle: Bundle?

    init(locale: Locale? = nil) {
        let preferences = locale.map { [$0.identifier(.bcp47)] } ?? Locale.preferredLanguages
        let language = Self.preferredLanguage(for: preferences)
        bundle = Self.bundle(for: language)
    }

    static func preferredLanguage(for preferences: [String]) -> String {
        Bundle.preferredLocalizations(
            from: Bundle.module.localizations,
            forPreferences: preferences + [fallbackLanguage]
        ).first ?? fallbackLanguage
    }

    func text(_ key: String) -> String {
        if let value = bundle?.localizedString(forKey: key, value: nil, table: nil), value != key {
            return value
        }
        return Self.bundle(for: Self.fallbackLanguage)?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }

    func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), arguments: arguments)
    }

    private static func bundle(for language: String) -> Bundle? {
        Bundle.module.url(forResource: language, withExtension: "lproj").flatMap { Bundle(url: $0) }
    }
}
