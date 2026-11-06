import Foundation

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

@MainActor
enum DeviceProfile {
    static var isPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    static var name: String {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        default: return UIDevice.current.model
        }
        #elseif os(watchOS)
        return WKInterfaceDevice.current().model
        #elseif os(tvOS)
        return "Apple TV"
        #elseif os(visionOS)
        return "Apple Vision Pro"
        #else
        return "Apple Device"
        #endif
    }

    static var symbol: String {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? "ipad.gen2" : "iphone.gen3"
        #elseif os(watchOS)
        return "applewatch"
        #elseif os(tvOS)
        return "appletv"
        #elseif os(visionOS)
        return "visionpro"
        #else
        return "desktopcomputer"
        #endif
    }

    static var system: String {
        #if os(iOS)
        return UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #elseif os(watchOS)
        return "watchOS " + WKInterfaceDevice.current().systemVersion
        #else
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }

    static var cleanupDescription: String {
        "Di iPhone dan iPad, Apple melindungi cache sistem dan aplikasi lain. DL7 hanya bisa menghapus cache serta file sementara milik DL7 sendiri."
    }
}
