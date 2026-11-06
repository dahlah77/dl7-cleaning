import SwiftUI

struct DL7HomeView: View {
    @State private var cache = CacheModel()
    @State private var confirmCleaning = false

    var body: some View {
        #if os(watchOS)
        NavigationStack {
            List {
                Section("Perangkat") { deviceCard }
                Section("Cache DL7") { cacheOverview }
                Section("Privasi") {
                    Text("Cache sistem dan aplikasi lain tidak dapat diakses.")
                        .font(.footnote)
                }
            }
            .navigationTitle("DL7 CLEANING")
        }
        .task { await cache.scan() }
        #else
        adaptiveTabs
            .task { await cache.scan() }
        #endif
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: DeviceProfile.symbol)
                    .font(.title2)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 4) {
                    Text("PERANGKAT TERDETEKSI")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(DeviceProfile.name)
                        .font(.title2.bold())
                }
                Spacer(minLength: 0)
            }
            Text(DeviceProfile.system)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var cacheOverview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ByteCountFormatter.string(fromByteCount: cache.snapshot.bytes, countStyle: .file))
                .font(.title.bold().monospacedDigit())
                .minimumScaleFactor(0.7)
            Text("Cache dan file sementara milik DL7")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(cache.snapshot.cacheCount) cache • \(cache.snapshot.temporaryCount) file sementara lama")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    #if !os(watchOS)
    @ViewBuilder
    private var adaptiveTabs: some View {
        #if os(iOS)
        if DeviceProfile.isPhone {
            tabs.tabViewStyle(.tabBarOnly)
        } else {
            tabs.tabViewStyle(.sidebarAdaptable)
        }
        #else
        tabs.tabViewStyle(.sidebarAdaptable)
        #endif
    }

    private var tabs: some View {
        TabView {
            Tab("Ringkasan", systemImage: "square.grid.2x2") {
                NavigationStack { overview }
            }
            Tab("Cache DL7", systemImage: "sparkles") {
                NavigationStack { cachePage }
            }
            Tab("Perangkat", systemImage: "iphone.gen3") {
                NavigationStack { devicePage }
            }
        }
    }

    private func page<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18, content: content)
                .padding(.horizontal, 18)
                .padding(.top, 14)
                // Reserve scrollable space above iOS 26+'s floating Liquid Glass tabs.
                .padding(.bottom, 132)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 13, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var overview: some View {
        page {
            VStack(alignment: .leading, spacing: 7) {
                Text("DL7 CLEANING")
                    .font(.title.bold())
                Text("Ruang bersih, kendali penuh.")
                    .foregroundStyle(.secondary)
            }
            deviceCard
            HStack(alignment: .top, spacing: 12) {
                metric("Bisa dibersihkan", value: ByteCountFormatter.string(fromByteCount: cache.snapshot.bytes, countStyle: .file), icon: "internaldrive")
                metric("File ditemukan", value: "\(cache.snapshot.entries.count)", icon: "doc.on.doc")
            }
            sectionCard {
                Label("Privasi tetap terlindungi", systemImage: "checkmark.shield")
                    .font(.headline)
                Text(DeviceProfile.cleanupDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ringkasan")
        .dl7CompactTitle()
    }

    private func metric(_ label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Image(systemName: icon).foregroundStyle(.cyan)
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var cachePage: some View {
        page {
            sectionCard {
                Label("Pembersihan aman", systemImage: "sparkles")
                    .font(.headline)
                cacheOverview

                if cache.busy { ProgressView("Memindai…") }
                if let error = cache.snapshot.error {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }

                if cache.snapshot.entries.isEmpty && !cache.busy {
                    Label("Cache DL7 sudah bersih", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Belum ada file cache yang perlu dibuang. Tombol bersihkan akan tersedia jika DL7 menemukan data sementara miliknya sendiri.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if !cache.snapshot.entries.isEmpty {
                    Button(role: .destructive) { confirmCleaning = true } label: {
                        Label("Bersihkan \(cache.snapshot.entries.count) File", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(cache.busy)
                }

                Button {
                    Task { await cache.scan() }
                } label: {
                    Label("Pindai Ulang", systemImage: "arrow.clockwise")
                }
                .disabled(cache.busy)
            }

            if !cache.snapshot.entries.isEmpty {
                sectionCard {
                    Text("Pratinjau file")
                        .font(.headline)
                    ForEach(cache.snapshot.entries) { entry in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.filename)
                                    .lineLimit(2)
                                Text(entry.area.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            Text(ByteCountFormatter.string(fromByteCount: entry.bytes, countStyle: .file))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Divider()
                    }
                }
            }

            sectionCard {
                Label("Kenapa cache iPhone lain tidak muncul?", systemImage: "lock.shield")
                    .font(.headline)
                Text("iOS tidak mengizinkan DL7 membaca atau menghapus cache Safari, WhatsApp, dan aplikasi lain. Untuk memeriksa ruang perangkat, buka Pengaturan → Umum → Penyimpanan iPhone.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("DL7 hanya menampilkan file yang benar-benar dapat dihapus. Tidak ada angka penghematan yang dibuat-buat.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Cache DL7")
        .dl7CompactTitle()
        .confirmationDialog("Hapus cache DL7 secara permanen?", isPresented: $confirmCleaning, titleVisibility: .visible) {
            Button("Hapus \(cache.snapshot.entries.count) File", role: .destructive) {
                Task { await cache.cleanConfirmed() }
            }
        } message: {
            Text("Hanya cache dan file sementara lama milik DL7. Foto, dokumen, cache sistem, dan aplikasi lain tidak disentuh.")
        }
        .alert("Hasil Pembersihan", isPresented: Binding(
            get: { cache.notice != nil },
            set: { if !$0 { cache.notice = nil } }
        )) { Button("OK") { cache.notice = nil } } message: {
            Text(cache.notice ?? "")
        }
    }

    private var devicePage: some View {
        page {
            deviceCard
            sectionCard {
                Text("Kemampuan")
                    .font(.headline)
                feature("Deteksi perangkat otomatis", symbol: "checkmark.circle.fill", positive: true)
                Divider()
                feature("Navigasi mengikuti Apple", symbol: "checkmark.circle.fill", positive: true)
                Divider()
                feature("Cache dan file sementara DL7", symbol: "checkmark.circle.fill", positive: true)
                Divider()
                feature("Cache sistem tidak dapat diakses", symbol: "lock.shield", positive: false)
            }
            sectionCard {
                Label("Privasi", systemImage: "hand.raised")
                    .font(.headline)
                Text("Tanpa akun, iklan, atau telemetri. Semua pemindaian DL7 berlangsung di perangkat ini.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Perangkat")
        .dl7CompactTitle()
    }

    private func feature(_ title: String, symbol: String, positive: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(positive ? Color.cyan : Color.secondary)
                .frame(width: 22)
            Text(title)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    #endif
}

private extension View {
    @ViewBuilder
    func dl7CompactTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
