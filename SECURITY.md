# Security Policy

## Prinsip utama

- DL7 tidak menghapus data tanpa tindakan pengguna dan dialog konfirmasi.
- Cleanup di iOS hanya dalam sandbox milik aplikasi DL7. Tidak ada bypass izin iOS, jailbreak, atau klaim pembersihan cache lintas aplikasi.
- Engine Mac dapat memindai area yang diberi izin pengguna. Selalu tinjau daftar kandidat sebelum menghapus.
- Tidak ada telemetri/akun yang dikonfigurasi pada companion. Alamat wallet dukungan tidak diisi secara bawaan; pembayaran hanya dilakukan pengguna melalui aplikasi wallet eksternal.
- Repo publik **tidak menerima** password, token API, provisioning profile, private key, file `.p12`, data aplikasi pribadi, atau crash log yang mengandung informasi sensitif.

## Melaporkan masalah

Untuk bug fungsional atau tampilan, gunakan GitHub Issues. Untuk potensi kerentanan, **jangan posting eksploitasi, password, atau data pribadi di issue publik**. Hubungi maintainer melalui kanal pribadi yang tercantum di profil GitHub hingga tersedia Private Vulnerability Reporting.

## Status dukungan

Build iPhone 11 dan Mac sudah diverifikasi pada v0.3.0. Watch, Apple TV, Vision Pro, penandatanganan distribusi, dan seluruh interaksi UI belum melalui QA perangkat fisik lengkap. Jangan gunakan aplikasi ini untuk menghapus data yang belum dicadangkan.
