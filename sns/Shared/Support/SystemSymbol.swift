import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum SystemSymbol {
    static func firstAvailable(_ names: [String], fallback: String) -> String {
        #if canImport(UIKit)
        names.first(where: { UIImage(systemName: $0) != nil }) ?? fallback
        #elseif canImport(AppKit)
        names.first(where: { NSImage(systemSymbolName: $0, accessibilityDescription: nil) != nil }) ?? fallback
        #else
        fallback
        #endif
    }
}
