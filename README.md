# DL7 CLEANING

**A cleaner built for Apple — native, personal, transparent.**

DL7 CLEANING adalah aplikasi utilitas Apple dengan antarmuka premium, pengenalan perangkat otomatis, navigasi bawaan Apple, dan kontrol warna yang dapat dipersonalisasi. Versi macOS mengadaptasi engine open-source [Havus](https://github.com/XNyetok/Havus) (MIT), sementara versi perangkat lain menggunakan SwiftUI dan mengikuti batas keamanan platform Apple.

> **Status publik: macOS v0.4.3 / iPhone v0.4.0.** Saat ini **tidak ada APK, IPA universal, DMG bernotarisasi, TestFlight, atau rilis App Store**. Pengguna membangun aplikasi menggunakan Mac dan Xcode. Versi macOS 0.4.3 menggunakan tata letak kolom eksplisit agar sidebar tidak pernah menutupi daftar aplikasi ketika ditampilkan; iPhone 0.4.0 telah diuji pada iPhone 11. Target lainnya masih eksperimental.

## Instalasi cepat

**Belum pernah menggunakan Xcode?** Baca **[Panduan Instalasi Lengkap Bahasa Indonesia](docs/INSTALL.md)** terlebih dahulu.

| Perangkat | Langkah awal | Status |
| --- | --- | --- |
| **Mac** | `zsh scripts/build-macos.sh` → buka folder `dist` → pindahkan `.app` ke Applications | Build + pemasangan diuji |
| **iPhone & iPad** | `zsh scripts/open-apple-project.sh` → pilih `DL7iOS` → pilih perangkat → Run ▶ | iPhone 11 diuji; iPad belum |
| Apple Watch | Pilih `DL7watchOS` di Xcode | Target eksperimental |
| Apple TV | Pilih `DL7tvOS` di Xcode | Target eksperimental |
| Apple Vision Pro | Pilih `DL7visionOS` di Xcode | Target eksperimental |

**Persiapan:** Mac dengan Xcode, internet, dan XcodeGen untuk target selain macOS (`brew install xcodegen`). Untuk memasang ke perangkat fisik, gunakan Apple Account untuk signing serta Developer Mode bila diminta. Profil gratis *Personal Team* kedaluwarsa setelah 7 hari.

## Tampilan dan personalisasi

Palet referensi bawaan:

| Parameter | Warna |
| --- | --- |
| Accent / Aksen | `#1EFF5A` |
| Background / Latar belakang | `#040805` |
| Foreground / Latar depan | `#3DFFF5` |

Ketiganya dapat diubah sendiri-sendiri melalui color picker atau kode HEX dan disimpan secara lokal. Setelan warna iPhone dan Mac **tidak otomatis disinkronkan**.

- iPhone/iPad: **Beranda • Bersihkan • Fitur • Setelan**.
- Mac: dashboard, sidebar native, tool cleanup Havus, **Fitur**, **Tampilan**, dan **Dukung DL7**.
- Satu navigasi **Fitur** menjelaskan kemampuan aplikasi tanpa memenuhi halaman utama dengan teks panjang.

## Kemampuan & batasan

**macOS:** pemindaian sampah sistem/developer, uninstaller, file besar, startup items (menggunakan modul Havus yang diadaptasi). Penghapusan tetap mengikuti pilihan dan konfirmasi pengguna. Beberapa operasi membutuhkan izin macOS.

**iOS/iPadOS:** mendeteksi perangkat, memindai cache milik DL7, membersihkan cache serta file sementara DL7 yang telah berumur lebih dari satu jam. **Apple tidak mengizinkan DL7 menghapus cache sistem, Safari, WhatsApp, atau data aplikasi lain.** Tidak ada angka penghematan palsu.

**watchOS/tvOS/visionOS:** target SwiftUI eksperimental dengan akses yang sesuai kemampuan sistem. Pengujian perangkat fisik dan penyempurnaan fitur masih diperlukan sebelum distribusi publik.

## Buy me a coffee — dukungan kripto

Tersedia UI dukungan dengan jaringan **BTC, SOL, ETH, BNB, dan USDT (BNB Smart Chain)**. Pemilik proyek sudah menetapkan alamat resmi berikut:

| Jaringan / aset | Alamat penerima |
| --- | --- |
| Bitcoin (BTC) | `bc1papfmgppu3h0qhw64eag54k80c8gc7um8ra7llng5u9fgxnyxlllsyu7p3s` |
| Solana (SOL) | `6KdxkUkTfTAVoenCyupBHvdRaNfoDDhUzhyjc4AdUXKU` |
| Ethereum (ETH) | `0xae91783b9e196f33535a4b45ba6fe041b149f7b9` |
| BNB (BNB Smart Chain) | `0xae91783b9e196f33535a4b45ba6fe041b149f7b9` |
| USDT (BNB Smart Chain, BEP-20) | `0xae91783b9e196f33535a4b45ba6fe041b149f7b9` |

Alamat tampil otomatis dan dapat disalin; tombol explorer membantu verifikasi tujuan. **USDT harus dikirim melalui BNB Smart Chain (BEP-20), bukan ERC-20 atau jaringan lain.** Wallet link hanya muncul untuk jaringan yang memiliki deep link sederhana; aplikasi tidak membuat atau menandatangani transaksi. Selalu verifikasi jaringan dan alamat sebelum mengirim kripto.

## Struktur repository

```text
DL7-CLEANING/
├── Companions/
│   ├── project.yml           # XcodeGen: iOS/iPadOS, watchOS, tvOS, visionOS
│   ├── Shared/               # SwiftUI, warna, cache, device detection
│   ├── Assets-iOS.xcassets/
│   └── Tests/
├── MacBranding/
│   ├── RootView.swift        # UI Mac premium
│   ├── HavusApp.swift
│   ├── Havus.xcconfig
│   └── apply_to_upstream_clone.sh
├── scripts/
│   ├── build-macos.sh
│   └── open-apple-project.sh
├── docs/INSTALL.md
├── LICENSE
└── LICENSE-UPSTREAM-HAVUS
```

`scripts/build-macos.sh` mengunduh source Havus pada commit terpilih, menerapkan branding dan UI DL7, lalu menghasilkan aplikasi **di direktori `dist` tanpa menghapus/mengubah aplikasi yang sudah terpasang**. Repo ini sengaja tidak mengunggah checkout Havus, cache build, provisioning profile, atau data Mac pribadi.

## Keamanan dan kontribusi

- [Kebijakan Keamanan](SECURITY.md) — cakupan izin, penghapusan, dan pelaporan kerentanan.
- [Panduan Kontribusi](CONTRIBUTING.md) — cara membangun, menguji, dan membuat pull request.
- [Riwayat Versi](CHANGELOG.md).

## Lisensi dan kredit

Dirilis dengan lisensi MIT. Terima kasih kepada **Debi Kurnia** dan kontributor [XNyetok/Havus](https://github.com/XNyetok/Havus) untuk engine macOS berlisensi MIT. Pernyataan hak cipta asli tersedia di [LICENSE-UPSTREAM-HAVUS](LICENSE-UPSTREAM-HAVUS) dan harus dipertahankan dalam distribusi turunan.

Proyek ini independen dan **tidak berafiliasi atau didukung oleh Apple**.
