import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Colors in the reference supplied by the DL7 owner. Every channel is user-editable.
enum DL7Palette {
    static let defaultAccent = "#1EFF5A"
    static let defaultBackground = "#040805"
    static let defaultForeground = "#3DFFF5"

    static func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        guard digits.count == 6, digits.unicodeScalars.allSatisfy({
            CharacterSet(charactersIn: "0123456789ABCDEFabcdef").contains($0)
        }) else { return nil }
        return "#" + digits.uppercased()
    }

    static func color(_ hex: String, fallback: String = defaultForeground) -> Color {
        let raw = normalized(hex) ?? normalized(fallback) ?? defaultForeground
        let value = Int(raw.dropFirst(), radix: 16) ?? 0x3DFFF5
        return Color(
            .sRGB,
            red: Double((value >> 16) & 0xff) / 255.0,
            green: Double((value >> 8) & 0xff) / 255.0,
            blue: Double(value & 0xff) / 255.0,
            opacity: 1
        )
    }

    static func hexString(_ color: Color) -> String {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        else { return defaultAccent }
        return String(format: "#%02X%02X%02X",
            Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))
        #elseif canImport(AppKit)
        guard let rgb = NSColor(color).usingColorSpace(.deviceRGB)
        else { return defaultAccent }
        let red = rgb.redComponent
        let green = rgb.greenComponent
        let blue = rgb.blueComponent
        return String(format: "#%02X%02X%02X",
            Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))
        #else
        return defaultAccent
        #endif
    }
}

struct DL7Colors {
    let accent: Color
    let background: Color
    let foreground: Color

    init(accent: String, background: String, foreground: String) {
        self.accent = DL7Palette.color(accent, fallback: DL7Palette.defaultAccent)
        self.background = DL7Palette.color(background, fallback: DL7Palette.defaultBackground)
        self.foreground = DL7Palette.color(foreground, fallback: DL7Palette.defaultForeground)
    }

    var surface: Color { Color.white.opacity(0.04) }
    var line: Color { foreground.opacity(0.14) }
}

enum DL7Donation {
    enum Network: String, CaseIterable, Identifiable {
        case bitcoin = "BTC"
        case ethereum = "ETH"
        case solana = "SOL"
        case bnb = "BNB"
        case usdtBSC = "USDT (BSC)"

        var id: String { rawValue }

        /// Project owner's publicly designated receiving address. Never user-editable in the donation UI.
        var address: String {
            switch self {
            case .bitcoin: "bc1papfmgppu3h0qhw64eag54k80c8gc7um8ra7llng5u9fgxnyxlllsyu7p3s"
            case .solana: "6KdxkUkTfTAVoenCyupBHvdRaNfoDDhUzhyjc4AdUXKU"
            case .ethereum, .bnb, .usdtBSC: "0xae91783b9e196f33535a4b45ba6fe041b149f7b9"
            }
        }

        var chainNote: String {
            switch self {
            case .bitcoin: "Bitcoin • mainnet"
            case .ethereum: "Ethereum • mainnet"
            case .solana: "Solana • mainnet"
            case .bnb: "BNB • BNB Smart Chain (BSC)"
            case .usdtBSC: "USDT • BNB Smart Chain (BEP-20)"
            }
        }

        var explorerURL: URL? {
            let prefix: String
            switch self {
            case .bitcoin: prefix = "https://mempool.space/address/"
            case .ethereum: prefix = "https://etherscan.io/address/"
            case .solana: prefix = "https://solscan.io/account/"
            case .bnb, .usdtBSC: prefix = "https://bscscan.com/address/"
            }
            return URL(string: prefix + address)
        }
    }

    static func isValid(address: String, network: Network) -> Bool {
        let value = address.trimmingCharacters(in: .whitespacesAndNewlines)
        switch network {
        case .bitcoin:
            let legacy = (value.hasPrefix("1") || value.hasPrefix("3")) && (26...35).contains(value.count)
            let segwit = value.lowercased().hasPrefix("bc1") && (42...90).contains(value.count)
            return (legacy || segwit) && value.rangeOfCharacter(from: .whitespacesAndNewlines) == nil
        case .ethereum, .bnb, .usdtBSC:
            return value.range(of: "^0x[0-9A-Fa-f]{40}$", options: .regularExpression) != nil
        case .solana:
            let alphabet = CharacterSet(charactersIn: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
            return (32...44).contains(value.count) && value.unicodeScalars.allSatisfy { alphabet.contains($0) }
        }
    }

    static func walletURL(network: Network) -> URL? {
        guard isValid(address: network.address, network: network) else { return nil }
        let prefix: String
        switch network {
        case .bitcoin: prefix = "bitcoin"
        case .ethereum: prefix = "ethereum"
        case .solana: prefix = "solana"
        // A generic ethereum: link can silently select the wrong chain/token.
        // For BNB / USDT on BSC, the user must explicitly select BEP-20 in their wallet.
        case .bnb, .usdtBSC: return nil
        }
        return URL(string: "\(prefix):\(network.address)")
    }
}
