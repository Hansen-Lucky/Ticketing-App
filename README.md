# 🎟️ Aplikasi Mobile Ticketing App

Ticketing App adalah aplikasi mobile berbasis Flutter yang mempermudah pengguna dalam membeli tiket secara digital. Aplikasi ini menyediakan berbagai metode pembayaran seperti tunai, kartu kredit, dan QRIS, serta memberikan bukti pembayaran digital dalam format PDF yang dapat diunduh. Data transaksi tersimpan secara real-time di Firebase.

---

## 👤 Identitas Pembuat

* **Nama**: Hansen Lucky Gunawan  
* **NIS**: 12309669  
* **Rombel**: PPLG XI-2  
* **Sekolah**: SMK Wikrama Bogor

---

## 🚀 Fitur-Fitur Utama

### 🏁 Halaman Depan (Onboarding)

* Memberikan pengenalan singkat fungsi aplikasi.
* Tombol “Get Started” untuk masuk ke halaman utama.

### 📋 Daftar Tiket (Home)

* Menampilkan tiket dari Firebase Firestore.
* Setiap tiket berisi: Nama, Jenis (Regular/VIP), dan Harga.
* Tombol “Beli” untuk lanjut ke proses pembayaran.

### 💳 Halaman Pembayaran

* Menampilkan detail tiket yang dipilih.
* Tiga metode pembayaran:
  * Tunai
  * Kartu Kredit
  * QRIS
* Tombol “Konfirmasi Bayar” untuk menyelesaikan pembelian.

### 💬 Pop-Up Metode Pembayaran

* Tampil sesuai metode yang dipilih:
  * Tunai: Info pembayaran langsung.
  * Kartu Kredit: Input nomor kartu.
  * QRIS: Menampilkan QR Code untuk e-wallet.

### 🧾 Bukti Pembayaran

* Menampilkan ringkasan pembelian: nama tiket, harga, tanggal, status.
* Tombol “Kembali” dan “Unduh Bukti”.

### 📥 Unduh Bukti Pembayaran PDF

* Menggunakan `pdf` package Flutter.
* Mengunggah ke Firebase Storage.
* Notifikasi “Berhasil diunduh”.
* Contoh: [Lihat PDF Bukti](https://drive.google.com/file/d/1EzPaB1CCnLgyMmfMra9Fa9Dpqu87modK/view?usp=sharing)

---

## 🧠 Tujuan Proyek

* Menghadirkan solusi digital dalam pembelian tiket yang praktis, cepat, dan terdokumentasi.
* Meningkatkan efisiensi proses transaksi dan dokumentasi.
* Memberikan pengalaman pengguna modern dan fleksibel melalui platform mobile berbasis Flutter.

---

## 🔧 Teknologi yang Digunakan

* Flutter
* Dart
* Firebase Firestore (Database)
* Firebase Storage
* Firebase Authentication (opsional)
* `pdf` & `printing` package Flutter

---

## 🧩 Spesifikasi Proyek

* **Pembelian tiket digital** melalui sistem real-time.
* **Dukungan berbagai metode pembayaran**: tunai, kartu kredit, QRIS.
* **Riwayat transaksi tersimpan** dan dapat diverifikasi ulang.
* **Desain antarmuka modern dan mobile-friendly**.
* **Bukti pembayaran dalam bentuk PDF** yang bisa diunduh.

---

## 🧭 Alur Aplikasi

1. Pengguna membuka aplikasi dan melihat halaman onboarding.
2. Melanjutkan ke halaman utama dan melihat daftar tiket.
3. Memilih tiket dan masuk ke halaman pembayaran.
4. Memilih metode pembayaran dan mengonfirmasi transaksi.
5. Melihat ringkasan pembayaran.
6. Mengunduh bukti pembayaran PDF.

---

## 📄 Lisensi

Aplikasi ini dikembangkan sebagai bagian dari proyek tugas sekolah oleh siswa SMK Wikrama Bogor untuk keperluan pembelajaran dan presentasi digital di bidang Teknologi Informatika.
