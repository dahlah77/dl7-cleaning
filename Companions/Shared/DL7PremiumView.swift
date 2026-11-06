#if os(iOS)
import SwiftUI
import UIKit

private enum PremiumTab: Hashable {
    case home, clean, features, settings
}

/// Distinct DL7 interface: native Apple navigation, minimal copy and customizable neon palette.
struct DL7PremiumView: View {
    @State private var cache = CacheModel()
    @State private var tab: PremiumTab = .home
    @State private var showConfirmation = false
    @State private var showSupport = false

    @AppStorage("dl7.palette.accent") private var accentHex = DL7Palette.defaultAccent
    @AppStorage("dl7.palette.background") private var backgroundHex = DL7Palette.defaultBackground
    @AppStorage("dl7.palette.foreground") private var foregroundHex = DL7Palette.defaultForeground
    @AppStorage("dl7.donation.network") private var donationNetwork = "BTC"
    @AppStorage("dl7.donation.address") private var donationAddress = ""
    @Environment(\.openURL) private var openURL

    private var colors: DL7Colors {
        DL7Colors(accent: accentHex, background: backgroundHex, foreground: foregroundHex)
    }

    private var bytes: String {
        ByteCountFormatter.string(fromByteCount: cache.snapshot.bytes, countStyle: .file)
    }

    var body: some View {
        Group {
            if DeviceProfile.isPhone {
                tabs.tabViewStyle(.tabBarOnly)
            } else {
                tabs.tabViewStyle(.sidebarAdaptable)
            }
        }
        .tint(colors.accent)
        .preferredColorScheme(.dark)
        .task { await cache.scan() }
    }

    private var tabs: some View {
        TabView(selection: $tab) {
            Tab("Beranda", systemImage: "square.grid.2x2.fill", value: PremiumTab.home) {
                NavigationStack { home }
            }
            Tab("Bersihkan", systemImage: "sparkles", value: PremiumTab.clean) {
                NavigationStack { cleaner }
            }
            Tab("Fitur", systemImage: "square.stack.3d.up", value: PremiumTab.features) {
                NavigationStack { features }
            }
            Tab("Setelan", systemImage: "slider.horizontal.3", value: PremiumTab.settings) {
                NavigationStack { settings }
            }
        }
    }

    private func page<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            colors.background.ignoresSafeArea()
            RadialGradient(colors: [colors.accent.opacity(0.12), .clear], center: .topTrailing,
                           startRadius: 12, endRadius: 410)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            ScrollView {
                VStack(alignment: .leading, spacing: 18, content: content)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 130)
                    .frame(maxWidth: 780)
                    .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(colors.foreground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(19)
            .background(RoundedRectangle(cornerRadius: 23).fill(colors.surface))
            .overlay(RoundedRectangle(cornerRadius: 23).strokeBorder(colors.line))
    }

    private func heading(_ title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(colors.accent)
            Text(title).font(.system(size: 18, weight: .semibold, design: .rounded))
            Spacer()
        }
    }

    private var branding: some View {
        HStack(spacing: 13) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 28))
                .foregroundStyle(colors.accent)
                .frame(width: 55, height: 55)
                .background(colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 17))
                .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(colors.accent.opacity(0.35)))
            VStack(alignment: .leading, spacing: 0) {
                Text("DL7").font(.system(size: 32, weight: .bold, design: .rounded)).tracking(1.5)
                Text("C L E A N I N G")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(colors.accent)
            }
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(colors.accent)
                .accessibilityLabel("Aman")
        }
    }

    private var home: some View {
        page {
            branding
            HStack(spacing: 9) {
                Image(systemName: DeviceProfile.symbol).foregroundStyle(colors.accent)
                Text(DeviceProfile.name).font(.subheadline.weight(.semibold))
                Spacer(minLength: 0)
                Text(DeviceProfile.system).font(.caption).foregroundStyle(.white.opacity(0.6))
            }
            .padding(15)
            .background(colors.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(colors.line))

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("POTENSI PEMBERSIHAN")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .tracking(1.3)
                    Spacer()
                    Circle().fill(colors.accent).frame(width: 9, height: 9)
                }
                Text(bytes)
                    .font(.system(size: 50, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                Label(cache.snapshot.entries.isEmpty ? "SUDAH BERSIH" : "SIAP DIBERSIHKAN",
                      systemImage: cache.snapshot.entries.isEmpty ? "checkmark.circle.fill" : "sparkles")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(colors.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 27)
                .fill(LinearGradient(colors: [colors.accent.opacity(0.21), colors.foreground.opacity(0.04), colors.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)))
            .overlay(RoundedRectangle(cornerRadius: 27).strokeBorder(colors.accent.opacity(0.3)))

            HStack(spacing: 12) {
                smallMetric("CACHE", value: cache.snapshot.cacheCount, icon: "archivebox")
                smallMetric("TEMPORARY", value: cache.snapshot.temporaryCount, icon: "clock.arrow.circlepath")
            }

            Button {
                tab = .clean
                Task { await cache.scan() }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Pindai & Bersihkan")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.headline)
                .padding(18)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.black)
            .background(colors.accent, in: RoundedRectangle(cornerRadius: 18))
        }
        .navigationTitle("DL7")
    }

    private func smallMetric(_ title: String, value: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon).foregroundStyle(colors.accent)
            Text("\(value)").font(.system(size: 27, weight: .bold, design: .rounded)).monospacedDigit()
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.57))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(colors.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(colors.line))
    }

    private var cleaner: some View {
        page {
            heading("Pembersihan", symbol: "sparkles")
            card {
                Text("TERDETEKSI")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(colors.accent)
                Text(bytes)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if cache.busy { ProgressView().tint(colors.accent) }
                if let error = cache.snapshot.error {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.caption).foregroundStyle(.orange)
                }
                HStack(spacing: 11) {
                    Button { Task { await cache.scan() } } label: {
                        Label("Pindai", systemImage: "arrow.clockwise").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(cache.busy)
                    Button(role: .destructive) { showConfirmation = true } label: {
                        Label("Bersihkan", systemImage: "trash").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(colors.accent)
                    .foregroundStyle(.black)
                    .disabled(cache.busy || cache.snapshot.entries.isEmpty)
                }
                if !cache.busy && cache.snapshot.entries.isEmpty {
                    Label("Sudah bersih", systemImage: "checkmark.circle.fill")
                        .font(.subheadline).foregroundStyle(colors.accent)
                }
            }
            if !cache.snapshot.entries.isEmpty {
                card {
                    heading("File ditemukan", symbol: "doc.on.doc")
                    ForEach(cache.snapshot.entries) { entry in
                        HStack(spacing: 9) {
                            Image(systemName: "doc.zipper").foregroundStyle(colors.accent)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.filename).lineLimit(1)
                                Text(entry.area.title).font(.caption2).foregroundStyle(.white.opacity(0.57))
                            }
                            Spacer(minLength: 0)
                            Text(ByteCountFormatter.string(fromByteCount: entry.bytes, countStyle: .file))
                                .font(.caption.monospacedDigit())
                        }
                        Divider().overlay(colors.line)
                    }
                }
            }
        }
        .navigationTitle("Bersihkan")
        .confirmationDialog("Bersihkan \(cache.snapshot.entries.count) file DL7?", isPresented: $showConfirmation) {
            Button("Bersihkan", role: .destructive) { Task { await cache.cleanConfirmed() } }
        } message: { Text("Hanya cache dan file sementara milik DL7.") }
        .alert("Pembersihan selesai", isPresented: Binding(
            get: { cache.notice != nil }, set: { if !$0 { cache.notice = nil } }
        )) { Button("OK") { cache.notice = nil } } message: { Text(cache.notice ?? "") }
    }

    private var features: some View {
        page {
            heading("Semua Fitur", symbol: "square.stack.3d.up.fill")
            feature("Deteksi perangkat", "Otomatis mengenali perangkat Apple.", icon: "iphone.gen3")
            feature("Pindai cache", "Mengukur cache DL7 secara lokal.", icon: "magnifyingglass")
            feature("File sementara", "Membersihkan file DL7 yang lama.", icon: "clock.arrow.circlepath")
            feature("Tema kustom", "Tiga warna dapat diubah terpisah.", icon: "paintpalette")
            feature("Privasi", "Tanpa akun, iklan, atau pelacakan.", icon: "lock.shield")
            card {
                Label("Batas iOS", systemImage: "info.circle").font(.headline)
                Text("Cache sistem dan aplikasi lain dilindungi Apple. DL7 hanya dapat menghapus data miliknya sendiri.")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.65))
            }
        }
        .navigationTitle("Fitur")
    }

    private func feature(_ title: String, _ subtitle: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(colors.accent)
                .frame(width: 46, height: 46)
                .background(colors.accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.60))
            }
            Spacer(minLength: 0)
        }
        .padding(17)
        .background(colors.surface, in: RoundedRectangle(cornerRadius: 19))
        .overlay(RoundedRectangle(cornerRadius: 19).strokeBorder(colors.line))
    }

    private var settings: some View {
        page {
            heading("Personalisasi", symbol: "slider.horizontal.3")
            card {
                HStack {
                    Text("WARNA").font(.caption.monospaced().weight(.semibold))
                    Spacer()
                    Text("KUSTOM").font(.caption.monospaced()).foregroundStyle(colors.accent)
                }
                colorRow("Aksen", hex: $accentHex, fallback: DL7Palette.defaultAccent)
                Divider().overlay(colors.line)
                colorRow("Latar belakang", hex: $backgroundHex, fallback: DL7Palette.defaultBackground)
                Divider().overlay(colors.line)
                colorRow("Latar depan", hex: $foregroundHex, fallback: DL7Palette.defaultForeground)
                Button("Reset warna referensi") {
                    accentHex = DL7Palette.defaultAccent
                    backgroundHex = DL7Palette.defaultBackground
                    foregroundHex = DL7Palette.defaultForeground
                }
                .font(.footnote).foregroundStyle(colors.accent)
            }
            card {
                heading("Dukung DL7", symbol: "cup.and.saucer.fill")
                Button { showSupport = true } label: {
                    HStack {
                        Text("Buy me a coffee")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.headline).padding(15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.black)
                .background(colors.accent, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .navigationTitle("Setelan")
        .sheet(isPresented: $showSupport) { supportSheet }
    }

    private func colorRow(_ title: String, hex: Binding<String>, fallback: String) -> some View {
        HStack(spacing: 8) {
            Text(title).font(.subheadline).lineLimit(1).minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            TextField("#RRGGBB", text: hex)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .frame(width: 78)
            ColorPicker(title, selection: Binding(
                get: { DL7Palette.color(hex.wrappedValue, fallback: fallback) },
                set: { hex.wrappedValue = DL7Palette.hexString($0) }
            ), supportsOpacity: false)
            .labelsHidden().frame(width: 35)
        }
        .padding(.vertical, 3)
    }

    private var supportSheet: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 18) {
                    Label("Buy me a coffee", systemImage: "cup.and.saucer.fill")
                        .font(.title2.bold()).foregroundStyle(colors.accent)
                    Text("Dukung pengembangan DL7 lewat kripto.")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.66))
                    Picker("Jaringan", selection: $donationNetwork) {
                        ForEach(DL7Donation.Network.allCases) { network in
                            Text(network.rawValue).tag(network.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("Alamat wallet penerima", text: $donationAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.subheadline, design: .monospaced))
                        .padding(13)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 13))

                    if let walletURL = DL7Donation.walletURL(
                        address: donationAddress,
                        network: DL7Donation.Network(rawValue: donationNetwork) ?? .bitcoin
                    ) {
                        Button("Buka Wallet") { openURL(walletURL) }
                            .buttonStyle(.borderedProminent).tint(colors.accent)
                        Button("Salin alamat") { UIPasteboard.general.string = donationAddress }
                            .foregroundStyle(colors.foreground)
                    } else {
                        Text("Alamat valid diperlukan sebelum tautan donasi aktif.")
                            .font(.caption).foregroundStyle(.white.opacity(0.65))
                    }
                    Spacer(minLength: 0)
                }
                .padding(24)
            }
            .navigationTitle("Dukung DL7")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Selesai") { showSupport = false }
                }
            }
            .preferredColorScheme(.dark)
        }
        .presentationDetents([.medium, .large])
    }
}
#endif
