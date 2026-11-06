# Contributing to DL7 CLEANING

Terima kasih atas minat membantu. Agar perubahan aman dan mudah direview:

1. Baca [README](README.md), [panduan instalasi](docs/INSTALL.md), dan [SECURITY](SECURITY.md).
2. Fork repo ini, buat branch kecil yang menjelaskan pekerjaan, lalu lakukan perubahan.
3. Jalankan build target yang relevan di Xcode. Sertakan model perangkat, versi OS, hasil pengujian, dan screenshot bila mengubah UI.
4. Untuk kode cleaner, pertahankan pengujian path sandbox, konfirmasi sebelum menghapus, dan batas izin tiap platform.
5. Jangan masukkan credential, provisioning profile, folder DerivedData, atau file pengguna.
6. Buka pull request dengan **Masalah → Solusi → Cara tes → Risiko**.

Perubahan yang menyentuh penghapusan data atau hak akses membutuhkan penjelasan risiko dan pengujian dengan file uji yang dapat dibuang, bukan data pengguna.

Havus adalah proyek MIT terpisah; modifikasi langsung pada engine upstream harus tetap mempertahankan atribusi/lisensi aslinya.
