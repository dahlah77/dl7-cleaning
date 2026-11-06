import AppKit
import HavusCore
import SwiftUI

private enum DL7Route: String, Hashable {
    case home, systemJunk, developerJunk, uninstaller, largeFiles, startupItems
    case features, appearance, support

    var label: String {
        switch self {
        case .home: "Beranda"
        case .systemJunk: "Sampah Sistem"
        case .developerJunk: "Sampah Developer"
        case .uninstaller: "Uninstaller"
        case .largeFiles: "File Besar"
        case .startupItems: "Startup"
        case .features: "Fitur"
        case .appearance: "Tampilan"
        case .support: "Dukung DL7"
        }
    }

    var symbol: String {
        switch self {
        case .home: "square.grid.2x2.fill"
        case .systemJunk: "sparkles"
        case .developerJunk: "hammer"
        case .uninstaller: "square.stack.3d.up.slash"
        case .largeFiles: "internaldrive"
        case .startupItems: "power"
        case .features: "square.stack.3d.up"
        case .appearance: "paintpalette"
        case .support: "cup.and.saucer.fill"
        }
    }
}

struct RootView: View {
    @Environment(PermissionCenter.self) private var permissions
    @Environment(ExclusionStore.self) private var exclusions

    @State private var selection: DL7Route = .home
    @State private var isSidebarVisible = true
    @State private var disk: DiskSpace?
    @State private var systemJunk = JunkCleanerModel(group: .system)
    @State private var developerJunk = JunkCleanerModel(group: .developer)
    @State private var uninstaller = UninstallerModel()
    @State private var largeFiles = LargeFilesModel()
    @State private var startupItems = StartupItemsModel()

    @AppStorage("dl7.palette.accent") private var accentHex = DL7Palette.defaultAccent
    @AppStorage("dl7.palette.background") private var backgroundHex = DL7Palette.defaultBackground
    @AppStorage("dl7.palette.foreground") private var foregroundHex = DL7Palette.defaultForeground
    @AppStorage("dl7.donation.network") private var donationNetwork = "BTC"

    private var selectedDonationNetwork: DL7Donation.Network {
        DL7Donation.Network(rawValue: donationNetwork) ?? .bitcoin
    }

    private var colors: DL7Colors {
        DL7Colors(accent: accentHex, background: backgroundHex, foreground: foregroundHex)
    }

    var body: some View {
        // Unlike NavigationSplitView, an explicit HStack never floats the
        // sidebar above Uninstaller's app list. Toggling it gives the detail
        // column real space rather than covering its leading edge.
        HStack(spacing: 0) {
            if isSidebarVisible {
                sidebar
                    .frame(width: 248)
                Rectangle()
                    .fill(colors.line)
                    .frame(width: 1)
            }
            detailPanel
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    isSidebarVisible.toggle()
                } label: {
                    Image(systemName: "sidebar.left")
                }
                .help(isSidebarVisible ? "Sembunyikan navigasi" : "Tampilkan navigasi")
                .accessibilityLabel(isSidebarVisible ? "Sembunyikan navigasi" : "Tampilkan navigasi")
            }
        }
        .preferredColorScheme(.dark)
        .tint(colors.accent)
        .onChange(of: exclusions.list, initial: true) { _, list in
            systemJunk.setExclusions(list)
            developerJunk.setExclusions(list)
            uninstaller.setExclusions(list)
            largeFiles.setExclusions(list)
            startupItems.setExclusions(list)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(colors.accent)
                    .frame(width: 42, height: 42)
                    .background(colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("DL7").font(.system(size: 23, weight: .bold, design: .rounded))
                    Text("C L E A N I N G")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(colors.accent)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 12)
            .accessibilityElement(children: .combine)

            List(selection: sidebarSelection) {
                row(.home)
                Section("BERSIHKAN") {
                    row(.systemJunk, badge: systemJunk.badge)
                    row(.developerJunk, badge: developerJunk.badge)
                }
                Section("KELOLA") {
                    row(.uninstaller)
                    row(.largeFiles)
                    row(.startupItems)
                }
                Section("DL7") {
                    row(.features)
                    row(.appearance)
                    row(.support)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
        .clipped()
    }

    private var detailPanel: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                colors.background
                RadialGradient(colors: [colors.accent.opacity(0.10), .clear],
                               center: .topTrailing, startRadius: 0, endRadius: 600)
                    .allowsHitTesting(false)
                detail
                    .frame(width: geometry.size.width, height: geometry.size.height,
                           alignment: .topLeading)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }

    private var sidebarSelection: Binding<DL7Route?> {
        Binding(get: { selection }, set: { if let value = $0 { selection = value } })
    }

    private func row(_ destination: DL7Route, badge: String? = nil) -> some View {
        Label(destination.label, systemImage: destination.symbol)
            .badge(badge.map { Text($0) })
            .tag(destination)
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .home: dashboard
        case .systemJunk: JunkCleanerView(model: systemJunk, page: .systemJunk)
        case .developerJunk: JunkCleanerView(model: developerJunk, page: .developerJunk)
        case .uninstaller: UninstallerView(model: uninstaller)
        case .largeFiles: LargeFilesView(model: largeFiles)
        case .startupItems:
            StartupItemsView(model: startupItems) { app in
                uninstaller.show(app)
                selection = .uninstaller
            }
        case .features: featuresPage
        case .appearance: appearancePage
        case .support: supportPage
        }
    }

    private func premiumPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 21, content: content)
                .padding(32)
                .frame(maxWidth: 940, alignment: .leading)
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(colors.foreground)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15, content: content)
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 22).fill(colors.surface))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(colors.line))
    }

    private func headline(_ title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(colors.accent)
            Text(title).font(.system(size: 20, weight: .semibold, design: .rounded))
            Spacer()
        }
    }

    private var dashboard: some View {
        premiumPage {
            HStack(spacing: 16) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(colors.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("DL7 CLEANING")
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .tracking(1.2)
                    Text("Mac • \(ProcessInfo.processInfo.operatingSystemVersionString)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.56))
                }
                Spacer()
                Label("AMAN", systemImage: "checkmark.shield.fill")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(colors.accent)
            }

            card {
                Text("RUANG TERSEDIA")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .tracking(1.3)
                    .foregroundStyle(colors.accent)
                Text(disk.map { Format.bytes($0.availableBytes) } ?? "—")
                    .font(.system(size: 54, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                if let disk {
                    ProgressView(value: disk.usedFraction)
                        .tint(colors.accent)
                    Text("\(Format.bytes(disk.usedBytes)) / \(Format.bytes(disk.totalBytes))")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.6))
                }
            }

            HStack(spacing: 13) {
                featureButton(.systemJunk)
                featureButton(.developerJunk)
                featureButton(.uninstaller)
            }
            HStack(spacing: 13) {
                featureButton(.largeFiles)
                featureButton(.startupItems)
                featureButton(.features)
            }
        }
        .task { disk = try? DiskSpace.startupDisk() }
    }

    private func featureButton(_ destination: DL7Route) -> some View {
        Button { selection = destination } label: {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: destination.symbol)
                    .font(.system(size: 23))
                    .foregroundStyle(colors.accent)
                HStack {
                    Text(destination.label).font(.headline)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right").font(.caption)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 95, alignment: .leading)
            .padding(19)
            .background(RoundedRectangle(cornerRadius: 20).fill(colors.surface))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(colors.line))
        }
        .buttonStyle(.plain)
        .foregroundStyle(colors.foreground)
    }

    private var featuresPage: some View {
        premiumPage {
            headline("Semua Fitur", symbol: "square.stack.3d.up.fill")
            guideRow("Sampah Sistem", "Pindai cache dan log macOS.", icon: "sparkles")
            guideRow("Sampah Developer", "Temukan cache dan hasil build.", icon: "hammer")
            guideRow("Uninstaller", "Hapus aplikasi dan file terkait.", icon: "square.stack.3d.up.slash")
            guideRow("File Besar", "Temukan file yang memakan ruang.", icon: "internaldrive")
            guideRow("Startup", "Kelola aplikasi saat Mac menyala.", icon: "power")
            guideRow("Tema & Privasi", "Warna bebas, semua proses lokal.", icon: "paintpalette")
        }
    }

    private func guideRow(_ name: String, _ subtitle: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(colors.accent)
                .frame(width: 54, height: 54)
                .background(colors.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 5) {
                Text(name).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.62))
            }
            Spacer()
        }
        .padding(17)
        .background(RoundedRectangle(cornerRadius: 18).fill(colors.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(colors.line))
    }

    private var appearancePage: some View {
        premiumPage {
            headline("Personalisasi", symbol: "paintpalette")
            card {
                HStack {
                    Text("WARNA").font(.caption.monospaced().weight(.semibold))
                    Spacer()
                    Text("KUSTOM").font(.caption.monospaced()).foregroundStyle(colors.accent)
                }
                macColorRow("Aksen", hex: $accentHex, fallback: DL7Palette.defaultAccent)
                Divider().overlay(colors.line)
                macColorRow("Latar belakang", hex: $backgroundHex, fallback: DL7Palette.defaultBackground)
                Divider().overlay(colors.line)
                macColorRow("Latar depan", hex: $foregroundHex, fallback: DL7Palette.defaultForeground)
                Button("Reset warna referensi") {
                    accentHex = DL7Palette.defaultAccent
                    backgroundHex = DL7Palette.defaultBackground
                    foregroundHex = DL7Palette.defaultForeground
                }
                .foregroundStyle(colors.accent)
            }
        }
    }

    private func macColorRow(_ title: String, hex: Binding<String>, fallback: String) -> some View {
        HStack(spacing: 14) {
            Text(title).font(.headline)
            Spacer()
            TextField("#RRGGBB", text: hex)
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.trailing)
                .frame(width: 115)
            ColorPicker(title, selection: Binding(
                get: { DL7Palette.color(hex.wrappedValue, fallback: fallback) },
                set: { hex.wrappedValue = DL7Palette.hexString($0) }
            ), supportsOpacity: false)
            .labelsHidden()
        }
        .padding(.vertical, 6)
    }

    private var supportPage: some View {
        premiumPage {
            headline("Buy me a coffee", symbol: "cup.and.saucer.fill")
            card {
                Text("Dukung pengembangan DL7 via kripto.")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.63))
                Picker("Jaringan", selection: $donationNetwork) {
                    ForEach(DL7Donation.Network.allCases) { network in
                        Text(network.rawValue).tag(network.rawValue)
                    }
                }
                .pickerStyle(.menu)
                Text(selectedDonationNetwork.chainNote)
                    .font(.subheadline).foregroundStyle(colors.accent)
                Text(selectedDonationNetwork.address)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    Button("Salin alamat") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(selectedDonationNetwork.address, forType: .string)
                    }
                    .buttonStyle(.borderedProminent)
                    if let walletURL = DL7Donation.walletURL(network: selectedDonationNetwork) {
                        Button("Buka Wallet") { NSWorkspace.shared.open(walletURL) }
                    }
                    if let explorerURL = selectedDonationNetwork.explorerURL {
                        Button("Lihat alamat") { NSWorkspace.shared.open(explorerURL) }
                    }
                }
                Text("Periksa jaringan sebelum mengirim. Untuk USDT gunakan BNB Smart Chain (BEP-20).")
                    .font(.caption).foregroundStyle(.white.opacity(0.61))
            }
        }
    }
}
