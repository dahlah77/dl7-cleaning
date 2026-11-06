# Panduan Instalasi DL7 CLEANING

Panduan ini ditulis untuk pengguna baru. **Satu source code mendukung beberapa perangkat Apple, tetapi aplikasi harus dibangun untuk sistem operasi masing-masing.** Saat ini belum tersedia distribusi resmi melalui App Store atau TestFlight.

## 1. Pilih perangkat

| Perangkat | Target proyek | Cara memasang | Status pengujian |
| --- | --- | --- | --- |
| Mac (macOS 14+) | Mac fork | Build di Mac, lalu salin `.app` ke Applications | **Sudah diuji** di Mac Intel |
| iPhone (iOS 18+) | `DL7iOS` | Jalankan melalui Xcode | **Sudah diuji** di iPhone 11 |
| iPad (iPadOS 18+) | `DL7iOS` | Sama dengan iPhone | Belum diuji di iPad fisik |
| Apple Watch (watchOS 11+) | `DL7watchOS` | Xcode + Apple Watch yang terpasang ke iPhone | Eksperimental; belum diuji perangkat fisik |
| Apple TV (tvOS 18+) | `DL7tvOS` | Pairing Apple TV di Xcode | Eksperimental; belum diuji perangkat fisik |
| Apple Vision Pro (visionOS 2+) | `DL7visionOS` | Pairing Vision Pro di Xcode | Eksperimental; belum diuji perangkat fisik |

> **Catatan jujur:** Mac menggunakan fitur Havus yang diadaptasi dan tetap meminta izin pengguna sebelum penghapusan. Di iPhone/iPad, Apple melarang aplikasi menghapus cache sistem atau aplikasi lain; DL7 hanya bisa membersihkan cache dan file sementara milik DL7 sendiri. Pada Apple Watch, halaman cache bersifat informasi saja.

## 2. Persiapan sekali saja

1. Siapkan **Mac yang mendukung Xcode** dan koneksi internet.
2. Pasang **Xcode** dari Mac App Store, buka sekali, dan selesaikan instalasi komponennya.
3. Untuk aplikasi selain Mac, buka **Xcode → Settings → Apple Accounts** dan masuk menggunakan Apple Account.
4. Unduh source project:

   ```bash
   git clone https://github.com/dahlah77/dl7-cleaning.git
   cd dl7-cleaning
   ```

   Belum mempunyai Git? Pasang Xcode Command Line Tools atau gunakan menu **Code → Download ZIP** di GitHub, lalu ekstrak ZIP. Buka Terminal pada folder `dl7-cleaning` yang telah diekstrak.

5. Untuk iPhone, iPad, Watch, TV, dan Vision, pasang **XcodeGen** (alat pembuat proyek Xcode). Jika menggunakan Homebrew:

   ```bash
   brew install xcodegen
   ```

   Jika `brew` belum ada, lihat [Homebrew](https://brew.sh/) atau instal XcodeGen dengan metode lain dari [repositori resminya](https://github.com/yonaskolb/XcodeGen).

## 3. Instal di Mac

Di Terminal, dalam folder project yang sudah diunduh:

```bash
zsh scripts/build-macos.sh
```

Script akan:

1. Mengunduh source Havus berlisensi MIT pada commit yang ditentukan.
2. Memasukkan identitas, warna, dan UI DL7 CLEANING.
3. Membangun aplikasi macOS Release dan menandatanganinya secara lokal.
4. Menyimpan hasil di `dist/DL7 CLEANING v0.4.2.app`.

**Langkah terakhir:** buka folder `dist` di Finder, lalu tarik aplikasi ke **Applications**. Buka DL7 CLEANING dari Launchpad/Finder.

- Jika sudah ada versi sebelumnya, **pindahkan versi lama ke folder cadangan dahulu**. Script build tidak menghapus aplikasi terpasang.
- macOS mungkin memerlukan konfirmasi keamanan karena ini build pengembangan, bukan rilis yang dinotarisasi Apple. Buka hanya jika Anda mempercayai source dan build tersebut. Jangan menonaktifkan Gatekeeper secara global.
- Kegiatan pembersihan dapat memerlukan izin akses berkas; baca target yang akan dibuang dan konfirmasi secara sadar.

## 4. Instal di iPhone atau iPad

1. Hubungkan iPhone/iPad ke Mac dengan kabel dan tekan **Trust / Percayai** jika diminta.
2. Di iPhone/iPad, buka **Settings → Privacy & Security → Developer Mode**, aktifkan, restart, lalu konfirmasi. Opsi ini biasanya muncul setelah perangkat dipasangkan dengan Xcode.
3. Pada Terminal di folder project, jalankan:

   ```bash
   zsh scripts/open-apple-project.sh
   ```

4. Xcode terbuka. Di bagian atas, pilih scheme **`DL7iOS`**.
5. Pilih iPhone/iPad yang terhubung sebagai **Run Destination**.
6. Klik target **DL7iOS → Signing & Capabilities**. Centang **Automatically manage signing**, lalu pilih **Team** milik Apple Account Anda.
7. Klik tombol **Run ▶** (atau `⌘R`). Tunggu hingga DL7 CLEANING terpasang dan terbuka di perangkat.

Jika menggunakan Apple Account gratis dengan **Personal Team**, profil instalasi berlaku selama **7 hari**. Setelah kedaluwarsa, buka proyek dan jalankan ulang dari Xcode. Ini adalah pembatasan Apple, bukan bug DL7.

## 5. Instal di Apple Watch

> **Eksperimental.** Source dan target disediakan, tetapi build penuh serta pengujian pada Apple Watch fisik belum dilakukan.

1. Pasangkan Apple Watch ke iPhone melalui aplikasi Watch.
2. Pastikan iPhone dan Apple Watch dapat dikenali Mac/Xcode.
3. Aktifkan **Developer Mode** di Apple Watch jika diminta, lalu restart.
4. Jalankan `zsh scripts/open-apple-project.sh` dari folder project.
5. Pilih scheme **`DL7watchOS`** dan Run Destination Apple Watch yang terhubung.
6. Pilih Team dan **Automatically manage signing**, lalu klik **Run ▶**.

Di Watch, DL7 menampilkan informasi perangkat/cache; tidak menyediakan penghapusan cache sistem.

## 6. Instal di Apple TV

> **Eksperimental.** Belum diuji pada Apple TV fisik.

1. Hubungkan Apple TV dan Mac ke jaringan yang sama.
2. Buka Xcode → **Device Hub / Manage Devices**, lakukan pairing Apple TV sesuai kode di layar.
3. Buka proyek menggunakan `zsh scripts/open-apple-project.sh`.
4. Pilih scheme **`DL7tvOS`**, pilih Apple TV sebagai Run Destination, atur Team, lalu **Run ▶**.

Apple TV **tidak memerlukan Developer Mode** seperti iPhone; pairing melalui Xcode menyediakan pengaturan pengembang.

## 7. Instal di Apple Vision Pro

> **Eksperimental.** Belum diuji pada Vision Pro fisik.

1. Pastikan dukungan visionOS tersedia di Xcode. Instal komponennya jika Xcode meminta.
2. Pasangkan Vision Pro dengan Xcode melalui Device Hub sesuai petunjuk perangkat.
3. Aktifkan **Developer Mode** pada Vision Pro dan konfirmasi restart jika diminta.
4. Buka proyek, pilih scheme **`DL7visionOS`** dan tujuan Vision Pro, atur signing, kemudian **Run ▶**.

## 8. Fitur, warna, dan dukungan

- **Warna:** buka **Setelan** (iPhone/iPad) atau **Tampilan** (Mac). Ubah *Aksen*, *Latar belakang*, dan *Latar depan* satu per satu melalui color picker atau kode HEX. Tombol Reset mengembalikan referensi bawaan.
- **Penjelasan fitur:** tersedia dalam satu navigasi bernama **Fitur**.
- **Donasi kripto:** buka **Dukung DL7 / Buy me a coffee**, pilih BTC, SOL, ETH, BNB, atau USDT (BNB Smart Chain). Alamat resmi tampil otomatis; tekan **Salin alamat** dan tempelkan di wallet. Untuk USDT gunakan **BNB Smart Chain (BEP-20)**. DL7 tidak mengirim uang otomatis.
- **Perbedaan Mac vs iPhone:** di Mac tersedia tool pembersihan sistem/developer berdasarkan akses pengguna. Di iPhone, cache sistem/aplikasi lain tetap terlindungi oleh sandbox iOS.

## 9. Masalah umum

| Gejala | Solusi awal |
| --- | --- |
| `xcodegen: command not found` | Instal XcodeGen, lalu ulangi `open-apple-project.sh`. |
| iPhone tidak muncul di Xcode | Sambungkan kabel, Trust perangkat, buka kunci iPhone, periksa Device Hub. |
| `Signing requires a development team` | Pilih Apple Account/Team di Signing & Capabilities. |
| `Developer Mode required` | Aktifkan Developer Mode lalu restart perangkat. |
| Aplikasi iPhone tidak terbuka setelah beberapa hari | Build dan jalankan ulang; profil Personal Team gratis berakhir setelah tujuh hari. |
| Target Watch/TV/Vision tidak ada | Pasang platform support di Xcode → Settings → Components; periksa versi OS minimum. |
| Pembersihan iPhone menunjukkan `0 B` | Tidak ada file DL7 yang memenuhi syarat; aplikasi tidak bisa mengakses cache aplikasi lain. |
| Tidak ada tombol Buka Wallet untuk BNB/USDT | Gunakan **Salin alamat** lalu buka wallet dan pilih BNB Smart Chain (BEP-20). Ini sengaja menghindari deep link ke jaringan yang salah. |

## Referensi Apple

- [Menjalankan app pada simulator/perangkat asli](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)
- [Mengaktifkan Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- [Memasangkan perangkat melalui Device Hub](https://developer.apple.com/documentation/xcode/pairing-your-devices-with-your-mac)
- [Aturan akun pengembang gratis (termasuk profil 7 hari)](https://developer.apple.com/help/account/basics/about-your-developer-account)

Jika Anda belum memiliki Mac/Xcode, source publik ini **belum dapat dipasang langsung hanya dengan mengetuk tautan GitHub pada iPhone**. Distribusi klik-pasang untuk publik membutuhkan proses penandatanganan dan penerbitan tersendiri (misalnya TestFlight/App Store).
