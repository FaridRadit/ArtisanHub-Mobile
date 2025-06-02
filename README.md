# ArtisanHub Mobile App (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7DAB46?style=for-the-badge&logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Aplikasi mobile ArtisanHub adalah platform inovatif yang bertujuan untuk menghubungkan pengguna dengan pengrajin lokal berbakat di area Yogyakarta dan sekitarnya. Aplikasi ini menampilkan produk-produk kerajinan tangan yang unik, informasi mengenai acara-acara yang berkaitan dengan seni dan kerajinan, serta menyediakan sistem notifikasi yang efisien. Dibangun dengan Flutter, aplikasi ini dirancang untuk berinteraksi secara mulus dengan API backend yang terpisah.

## Daftar Isi

* [Fitur Utama](#fitur-utama)
* [Teknologi yang Digunakan](#teknologi-yang-digunakan)
* [Persyaratan Sistem](#persyaratan-sistem)
* [Instalasi](#instalasi)
* [Konfigurasi](#konfigurasi)
* [Penggunaan](#penggunaan)
* [Struktur Proyek](#struktur-proyek)
* [Backend API](#backend-api)
* [Kontribusi](#kontribusi)
* [Lisensi](#lisensi)
* [Kontak](#kontak)

## Fitur Utama

* **Autentikasi Pengguna**:
    * Sistem login dan registrasi yang aman dengan peran `user` atau `artisan`. Role `admin` tidak tersedia melalui registrasi publik, ditambahkan secara manual di database backend.
    * Implementasi persistent login, memungkinkan pengguna tetap masuk hingga mereka secara eksplisit logout.
* **Halaman Beranda Interaktif**:
    * Tampilan peta interaktif menggunakan OpenStreetMap.
    * Fungsi pemilihan lokasi dengan marker yang dapat dipindahkan di peta.
    * **Untuk Pengrajin (Artisan)**: Ketika role pengguna adalah `artisan`, mengetuk lokasi di peta akan memunculkan popup formulir untuk membuat atau memperbarui profil pengrajin, dengan data latitude dan longitude dari titik yang dipilih otomatis terisi.
    * Bilah pencarian untuk mencari pengrajin berdasarkan nama, bio, atau kategori keahlian.
    * Daftar pengrajin yang relevan ditampilkan di bawah peta, menampilkan gambar profil, nama, dan kategori keahlian.
    * Mengklik item pengrajin di daftar akan memindahkan marker peta ke lokasi pengrajin tersebut dan menampilkan detail profil pengrajin dalam sebuah popup di tengah layar.
* **Profil Pengguna Dinamis**:
    * Menampilkan detail profil pengguna lengkap (username, email, nama lengkap, role, nomor telepon, URL gambar profil, tanggal bergabung).
    * **Untuk Pengrajin**: Jika pengguna ber-role `artisan`, profil pengrajin mereka (bio, kategori keahlian, alamat, rating rata-rata, total ulasan, status verifikasi, email kontak, telepon kontak, URL website) akan ditampilkan.
    * Tombol aksi spesifik berdasarkan peran (role) pengguna:
        * **`user`**: Tombol "Edit Profil" yang mengarah ke halaman `EditProfileUserScreen` untuk pembaruan data pengguna.
        * **`artisan`**: Tombol "Tambah/Kelola Produk" yang mengarah ke halaman `ProductScreen` untuk manajemen produk mereka.
        * **`admin`**: Tombol "Manajemen Acara" yang mengarah ke halaman `EventsScreen` untuk pengelolaan acara.
* **Pengaturan Aplikasi**:
    * Fungsionalitas konversi mata uang, mendukung konversi antara IDR, USD, EUR, dan JPY (sesuai contoh).
    * Fungsionalitas konversi waktu, menampilkan waktu saat ini di berbagai zona waktu (WIB, WIT, WITA, London GMT).
* **Notifikasi**:
    * Fitur registrasi device token untuk menerima notifikasi push.
    * Kemampuan untuk melihat daftar notifikasi yang diterima.
    * Opsi untuk menandai notifikasi sebagai sudah dibaca.

## Teknologi yang Digunakan

* **Flutter**: Framework UI utama untuk membangun aplikasi mobile secara native dari satu codebase.
* **Dart**: Bahasa pemrograman yang digunakan oleh Flutter.
* **`http`**: Paket untuk melakukan panggilan API RESTful ke backend.
* **`shared_preferences`**: Paket untuk menyimpan data sederhana secara lokal di perangkat, digunakan untuk mempertahankan status login.
* **`flutter_map` & `latlong2`**: Paket-paket penting untuk integrasi peta OpenStreetMap dan penanganan koordinat geografis.
* **`intl`**: Paket untuk internasionalisasi dan lokalisasi, digunakan dalam format angka, mata uang, dan tanggal/waktu.

## Persyaratan Sistem

* [Flutter SDK](https://flutter.dev/docs/get-started/install) terinstal dan terkonfigurasi (Versi stabil terbaru direkomendasikan).
* Lingkungan Pengembangan Terintegrasi (IDE) seperti [VS Code](https://code.visualstudio.com/) dengan ekstensi Flutter/Dart, atau [Android Studio](https://developer.android.com/studio).
* [Android SDK](https://developer.android.com/studio) terinstal untuk pengembangan Android, atau [Xcode](https://developer.apple.com/xcode/) untuk pengembangan iOS.
* Koneksi internet aktif untuk mengambil dependensi, data peta, dan berinteraksi dengan API backend.

## Instalasi

1.  **Clone repositori:**
    ```bash
    git clone [https://github.com/](https://github.com/)[YOUR_USERNAME]/[YOUR_REPO_NAME].git
    cd [YOUR_REPO_NAME]
    ```
    *(Ganti `[YOUR_USERNAME]` dan `[YOUR_REPO_NAME]` dengan informasi repositori Anda.)*

2.  **Dapatkan dependensi Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Bersihkan cache build (sangat direkomendasikan untuk mencegah masalah build):**
    ```bash
    flutter clean
    ```

4.  **Jalankan aplikasi:**
    Pastikan Anda memiliki emulator Android/iOS yang berjalan atau perangkat fisik yang terhubung.
    ```bash
    flutter run
    ```
    Atau jalankan dari IDE Anda (VS Code, Android Studio).

## Konfigurasi

Aplikasi ini berinteraksi dengan API backend yang sudah di-deploy.

* **URL Backend API**:
    URL dasar API sudah dikonfigurasi di `lib/config/api_config.dart`.
    ```dart
    // lib/config/api_config.dart
    class ApiConfig {
      static const String baseUrl = '[https://backendartisanhub-130852023885.asia-southeast2.run.app/api](https://backendartisanhub-130852023885.asia-southeast2.run.app/api)';
      static const String baseAuthUrl = '[https://backendartisanhub-130852023885.asia-southeast2.run.app/api/auth](https://backendartisanhub-130852023885.asia-southeast2.run.app/api/auth)';
    }
    ```
    Jika URL backend Anda berubah atau Anda ingin menggunakan instance lokal, perbarui nilai-nilai ini.

* **Package Name untuk OpenStreetMap**:
    Pastikan `userAgentPackageName` di `lib/screens/homepage.dart` di dalam `TileLayer` dari `FlutterMap` sesuai dengan `package name` aplikasi Anda. Ini adalah praktik terbaik untuk atribusi OpenStreetMap.
    Anda dapat menemukan package name Anda di `pubspec.yaml` (dibawah `name: your_app_name`) atau di `android/app/src/main/AndroidManifest.xml` (atribut `package` di tag `<manifest>`).
    ```dart
    // di dalam TileLayer pada FlutterMap di lib/screens/homepage.dart
    userAgentPackageName: 'com.example.artisanhub11', // Ganti dengan package name aplikasi Anda yang sebenarnya
    ```
    *(Contoh: Jika package name Anda `com.mycompany.artisanhub`, ubah ini sesuai.)*

## Penggunaan

1.  **Halaman Startup**: Saat pertama kali membuka aplikasi, akan ada layar loading singkat saat aplikasi memeriksa status login Anda.
2.  **Login/Register**: Jika Anda belum login, Anda akan diarahkan ke halaman login. Anda dapat mendaftar sebagai `user` atau `artisan` melalui formulir registrasi.
3.  **Homepage (Beranda)**: Setelah login berhasil, Anda akan melihat halaman beranda yang menampilkan peta interaktif dan area pencarian pengrajin.
    * **Peta**: Ketuk di mana saja di peta untuk memindahkan marker ke lokasi tersebut dan melihat koordinat lintang/bujur yang diperbarui.
    * **Profil Pengrajin (Role Artisan)**: Jika Anda login sebagai `artisan`, mengetuk peta juga akan memicu dialog "Buat Profil Pengrajin" di mana Anda dapat mengisi detail profil dan menyimpannya ke lokasi yang dipilih.
    * **Pencarian Pengrajin**: Gunakan bilah pencarian untuk mencari pengrajin. Hasil akan ditampilkan di bawah peta.
    * **Detail Pengrajin**: Klik pada item pengrajin di daftar untuk memindahkan marker peta ke lokasi mereka dan menampilkan detail profil lengkap pengrajin dalam sebuah popup.
4.  **Bottom Navigation Bar**: Gunakan navigasi bawah untuk berpindah antar halaman utama aplikasi:
    * **Beranda**: Halaman utama dengan peta dan fungsionalitas pencarian pengrajin.
    * **Profil**: Menampilkan detail profil pribadi Anda dan detail profil pengrajin (jika Anda adalah artisan), serta tombol aksi spesifik role.
    * **Saran & Kesan**: Halaman untuk mengirimkan masukan atau umpan balik kepada pengembang aplikasi.
    * **Pengaturan**: Halaman dengan fungsionalitas konversi mata uang dan konversi waktu.
    * **Acara** (khusus Admin): Halaman manajemen acara yang hanya dapat diakses oleh pengguna dengan role `admin`.
5.  **Logout**: Tombol logout tersedia di `AppBar` di halaman Beranda. Mengkliknya akan menghapus sesi Anda dan mengarahkan Anda kembali ke halaman login.

## Struktur Proyek

Struktur folder proyek di dalam `lib/` diorganisir sebagai berikut:
