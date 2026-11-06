# Changelog

## 0.4.4 (macOS) / 0.4.1 (iPhone) — 2026-11-06

- Menambahkan tautan **DEVELOPER** pada sidebar macOS dan tab iPhone/iPad untuk membuka portofolio di browser eksternal.
- Tab iPhone mengembalikan pilihan sebelumnya setelah membuka browser sehingga tidak meninggalkan halaman kosong.
- Bundle identifier tetap sama sehingga pembaruan menggantikan versi sebelumnya tanpa membuat aplikasi kedua.
- Build, instalasi, dan peluncuran macOS 0.4.4 serta iPhone 0.4.1 berhasil diverifikasi pada Mac Intel dan iPhone 11 (7 November 2026).
- Memperbaiki pendeteksian root installer saat dijalankan lewat fungsi zsh, serta menangani folder source non-repository dengan checkout terpisah tanpa mengubah data lama.

## Installer dan dokumentasi — 2026-11-06

- Menambahkan installer Terminal satu perintah dengan menu Mac, iPhone, iPad, Apple Watch, Apple TV, Apple Vision Pro, atau semua perangkat.
- Installer membuat backup sebelum mengganti aplikasi Mac, menyiapkan source/XcodeGen, dan membuka Xcode untuk target yang membutuhkan signing pengguna.
- Menambahkan mode `--dry-run`, opsi `--platform`, serta smoke test menu perangkat. Tidak mengubah engine pembersihan maupun versi aplikasi.

## 0.4.3 (macOS) — 2026-11-06

- Menghilangkan overlay sidebar pada Uninstaller secara struktural. Layout utama memakai `HStack` dengan sidebar berlebar tetap dan panel detail fleksibel, sehingga lebar panel aplikasi selalu berkurang saat navigasi muncul.
- Tombol tampil/sembunyikan navigasi tetap ada di toolbar macOS dan menggunakan ikon SF Symbols.
- Menambahkan pemeriksaan build yang menolak penggunaan `NavigationSplitView` di root agar daftar aplikasi tidak kembali tersembunyi di bawah navigasi.
- Tidak ada perubahan terhadap operasi pembersihan maupun aplikasi iPhone.

## 0.4.2 (macOS) — 2026-11-06

- Memperbaiki regresi navigasi v0.4.1 yang terlihat di rekaman layar: saat sidebar dibuka, daftar Uninstaller tertutup karena style `prominentDetail` menggunakan overlay.
- Mengembalikan `NavigationSplitView` ke mode `balanced`, mempertahankan pembatasan ukuran dan header sidebar yang diperbaiki pada v0.4.1.
- Pembaruan ini hanya untuk Mac, tanpa mengubah engine pembersihan, data pengguna, maupun aplikasi iPhone.
- Menambahkan pemeriksaan source sebelum build agar gaya sidebar overlay tidak terpakai kembali tanpa sengaja.

## 0.4.1 (macOS) — 2026-11-06

- Memperbaiki sidebar yang bisa terpotong atau bergeser saat berpindah fitur dan mengubah ukuran jendela.
- Memisahkan header brand dari daftar navigasi, sehingga header tetap terlihat dan item menu mempunyai area scroll sendiri.
- Membatasi setiap halaman fitur ke ukuran panel detail untuk mencegah konten menimpa titlebar, sidebar, atau keluar dari batas jendela.
- Mempertahankan build iPhone pada versi 0.4.0 karena perubahan ini khusus untuk macOS.

## 0.4.0 — 2026-11-06

- Build, instalasi, dan peluncuran diverifikasi pada Mac Intel dan iPhone 11. Pembaruan iPhone menggunakan bundle identifier yang sama sehingga tidak membuat salinan aplikasi baru.

- Alamat donasi resmi ditetapkan oleh pemilik proyek untuk BTC, SOL, ETH, BNB, dan USDT di BNB Smart Chain (BEP-20).
- Alamat tampil otomatis sesuai jaringan dan tidak dapat diubah menjadi alamat penerima lain dari UI.
- Menu pemilihan jaringan kini sesuai ukuran iPhone dan Mac; tersedia salin alamat, tautan explorer, dan wallet link hanya jika jaringan aman untuk deep link sederhana.
- Memberi penanda jaringan eksplisit agar pengguna tidak mengirim USDT melalui chain yang salah.

## 0.3.0 — 2026-11-06

- Identitas visual premium berbeda dari Havus.
- Palet neon-hijau/hitam/sian dengan tiga warna yang dapat disesuaikan sendiri dan disimpan otomatis.
- Navigasi native dan halaman khusus **Fitur** pada iPhone dan Mac.
- Halaman **Buy me a coffee** yang mendukung pengaturan BTC, ETH, SOL tanpa alamat fiktif.
- Build Release macOS serta build iPhone berhasil; kedua aplikasi dipasang dan diluncurkan pada perangkat pengujian.

## 0.2.0 — 2026-11-06

- Memperbaiki konfigurasi launch screen iPhone agar berjalan fullscreen.
- Memperbaiki ruang aman konten untuk tab bar bawaan Apple.
- Pembersihan aman cache dan file sementara lama milik DL7.

## 0.1.0 — 2026-11-05

- Fork terpisah Havus untuk Mac dan source companion SwiftUI untuk perangkat Apple.
