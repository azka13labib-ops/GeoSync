# GeoSync

Sistem Absensi Enterprise, Geofencing, dan Manajemen Tenaga Kerja Terpadu

---

## 1. Ikhtisar Proyek

GeoSync adalah aplikasi manajemen absensi dan tenaga kerja bermutu enterprise yang tangguh, aman, dan modern, dirancang untuk korporasi skala besar, pabrik, dan organisasi yang memiliki jaringan banyak kantor cabang.

Dibangun dengan arsitektur **Aplikasi Tunggal Terpadu (Single Unified Application)**, GeoSync memanfaatkan satu basis kode Flutter terkoordinasi yang secara dinamis mengubah antarmuka antara dasbor manajemen eksekutif (HRD) dan portal absensi karyawan berdasarkan hak peran (role) pengguna. Sistem ini memberlakukan standar keamanan berlapis tinggi, memadukan penguncian identitas perangkat seluler (Hardware Device UUID Binding), verifikasi batasan geografi GPS (Geofencing), dan aturan kriptografi Row-Level Security (RLS) untuk menghapus praktik kecurangan absensi seperti titip absen (*buddy punching*) maupun pemalsuan lokasi (*mock GPS*).

---

## 2. Filosofi Arsitektur Utama

GeoSync beroperasi di atas tiga pilar desain mendasar:
1. **Sistem Dua Peran dalam Satu Aplikasi**: Satu aplikasi melayani Karyawan reguler maupun Administrator Eksekutif (HRD). Pemetaan navigasi dan tampilan antarmuka diatur secara otomatis melalui verifikasi token JWT dan peran pada tabel relasional.
2. **Tanpa Pendaftaran Publik**: Untuk mencegah akses liar, registrasi akun publik dinaikan (dinonaktifkan). Akun karyawan hanya dapat didaftarkan oleh Administrator yang sah melalui eksekusi server awam terisolasi (Edge Function) tanpa memproses pengeluaran (logout) pada sesi aplikasi sang Administrator itu sendiri.
3. **Pertahanan Keamanan Berlapis**: Penindakan anti-curang berjalan serempak di sisi klien (pemeriksaan Hardware UUID pada penyimpanan terenkripsi dan deteksi aplikasi pemalsu GPS) serta di sisi database cloud (kebijakan PostgreSQL RLS dan stempel waktu atomatik dari server).

---

## 3. Fitur & Kemampuan Sistem

### Untuk Karyawan
- **Autentikasi Universal & Penguncian Perangkat (Device Binding)**: Masuk menggunakan kombinasi NIK dan Kata Sandi resmi dari HRD. Login perdana otomatis mengunci akun karyawan pada kode UUID perangkat seluler, menolak seketika segala percobaan masuk pada perangkat asing yang berbeda.
- **Absensi Presisi Berbasis Geofencing**: Memverifikasi koordinat GPS ponsel karyawan terhadap batasan radius kantor cabang menggunakan komputasi jarak spasial sebelum mengizinkan transmisi absensi.
- **Verifikasi Liveness Selfie**: Mewajibkan pengambilan foto potret langsung melalui kamera pada saat absensi masuk maupun pulang untuk meyakinkan kehadiran fisik di lapangan.
- **Portal Pengajuan Cuti & Rekonsiliasi**: Fasilitas mandiri untuk pengajuan izin cuti, pemantauan sisa kuota hari cuti tahunan, serta log riwayat absensi pribadi.

### Untuk Administrator (HRD / Eksekutif)
- **Dasbor Analitik Eksekutif**: Rangkuman pemantauan kehadiran tenaga kerja secara langsung (*real-time*), statistik tingkat kedisiplinan ketepatan waktu, dan pengingat keputusan persetujuan.
- **Pendaftaran Karyawan Terenkripsi**: Pembuatan kredensial staf dan akun pengelola secara aman menggunakan fungsi eksekusi cloud Deno/TypeScript tanpa celah eror *self-logout*.
- **Konfigurasi Jam Kerja Dinamis per Cabang**: Penetapan jam kerja yang disesuaikan untuk masing-masing kantor cabang, meliputi batas pembukaan absensi jam masuk, tenggang toleransi keterlambatan (dalam menit), dan jam absensi pulang.
- **Ekspor Laporan Payroll Sepenuhnya Otomatis**: Pembuatan dan penyusun lembar kerja Excel (XLSX) laporan absensi perusahaan dalam satu klik untuk pemrosesan gaji HRD.

---

## 4. Stack Teknologi

| Lapisan | Teknologi | Kegunaan |
| :--- | :--- | :--- |
| **Aplikasi Klien Mobile** | Flutter & Dart | Aplikasi lintas platform performa tinggi untuk Android & iOS |
| **Manajemen State** | Flutter Riverpod (v2+) | Pengatur aliran data reaktif dan siklus hidup komponen |
| **Navigasi & Perutean** | GoRouter | Sistem navigasi deklaratif berbasis peran dan proteksi halaman |
| **Antarmuka Pengguna** | Vanilla Material 3 + Token Glassmorphic | Tema eksekutif mode gelap dengan kontras visual tinggi |
| **Database & API Cloud** | Supabase (PostgreSQL) | Basis data relasional berskala tinggi dan API PostgREST instan |
| **Lapisan Keamanan** | PostgreSQL RLS & Crypt | Aturan enkripsi dan pembatasan akses data dari server |
| **Runtime Backend** | Deno & TypeScript | Supabase Edge Functions untuk isolasi proses administrasi |

---

## 5. Struktur Direktori Repositori

```text
GeoSync/
├── backend/
│   ├── 001_initial_schema.sql         # Skema relasional database, tabel ENUM, indeks, dan aturan RLS
│   └── supabase/
│       └── functions/
│           └── create-employee/       # Kode Deno/TS Edge Function untuk pendaftaran karyawan oleh Admin
├── docs/
│   ├── PRD.md                         # Dokumen Persyaratan Produk (PRD) dan acuan final
│   ├── architecture.md                # Diagram arsitektur teknis dan alur komunikasi sistem
│   ├── database.md                    # Kamus data, relasi antar tabel, dan catatan migrasi SQL
│   ├── design-system.md               # Token desain visual, palet warna korporat, dan spesifikasi komponen
│   └── tasks/                         # Buku catatan pemecahan modul dan pengembangan berjenjang
└── mobile/                            # Kode sumber aplikasi mobile Flutter
    ├── lib/
    │   ├── core/                      # Modul konstan, wrapper jaringan Supabase, tema, dan utilitas dasar
    │   ├── features/                  # Modul fitur mandiri (Auth, Attendance, Admin)
    │   └── navigation/                # Konfigurasi GoRouter dan pengawas rute per peran (Router Guard)
    └── pubspec.yaml                   # Daftar dependensi resmi dan spesifikasi paket versi
```

---

## 6. Panduan Instalasi & Konfigurasi

### Persyaratan Sistem (Prerequisites)
- **Flutter SDK**: Versi 3.24 atau lebih tinggi beserta kelengkapan compiler Android/iOS.
- **Sistem Windows**: Fitur Developer Mode pada pengaturan Windows wajib diaktifkan (ON) guna mendukung pembuatan *symbolic links* untuk plugin keamanan dan pustaka native.
- **Akun & CLI Supabase**: Dibutuhkan untuk pengujian lokal atau penghubungan instans cloud database.

### Langkah 1: Migrasi Database (Supabase)
1. Masuk ke konsol dasbor proyek Supabase Anda dan buka menu SQL Editor.
2. Jalankan seluruh perintah SQL dari file `backend/001_initial_schema.sql` untuk menciptakan fondasi tabel (`departments`, `office_locations`, `employees`, `work_hour_settings`, `attendance`, `leave_requests`, dan `audit_logs`).
3. Pastikan proteksi Row-Level Security (RLS) pada seluruh tabel aktif sesuai instruksi pada skema database.

### Langkah 2: Keamanan Variabel Lingkungan (Environment Variables)
Demi menjaga keamanan siber perusahaan, dilarang menyertakan atau menyimpan kunci API rahasia serta tautan database publik ke dalam riwayat repositori git secara permanen. Untuk mengintegrasikannya secara aman:

1. Buka file konfigurasi internal aplikasi mobile pada rute `mobile/lib/core/constants/app_constants.dart` atau gunakan skema masukan environment variable sewaktu proses kompilasi.
2. Rekomendasi penerapan injeksi rahasia tanpa menyimpan variabel di sistem kode:

```dart
class AppConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: 'YOUR_SUPABASE_PROJECT_URL',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY', 
    defaultValue: 'YOUR_SUPABASE_PUBLISHABLE_ANON_KEY',
  );
}
```

Saat melakukan pengujian atau pencetakan rilis (build), masukkan variabel secara aman melalui parameter terminal:
```bash
flutter run --dart-define=SUPABASE_URL=https://myproject.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=token_publishable_anda_di_sini
```

### Langkah 3: Penerapan Backend Edge Function
Agar fitur registrasi karyawan baru oleh Admin berfungsi secara aman dari cloud tanpa menggangu sesi login pemanggilnya, unggah Edge Function ke server Supabase Anda:

```bash
cd backend
supabase functions deploy create-employee --project-ref YOUR_PROJECT_REFERENCE_ID
```

Pastikan variabel pengaman `SUPABASE_SERVICE_ROLE_KEY` telah diotorisasi secara tertutup di dalam pengaturan rahasia cloud Supabase Anda. Dilarang keras melewatkan Service Role Key ke dalam kode antarmuka aplikasi Flutter.

### Langkah 4: Kompilasi & Menjalankan Aplikasi Mobile
1. Buka direktori root mobile:
   ```bash
   cd mobile
   ```
2. Sinkronkan dan unduh pustaka dependensi proyek:
   ```bash
   flutter pub get
   ```
3. Lakukan verifikasi linter kode resmi guna kepantasan standar perakitan:
   ```bash
   flutter analyze
   ```
4. Jalankan aplikasi pada perangkat seluler fisik atau emulator aktif:
   ```bash
   flutter run
   ```

---

## 7. Filosofi Commit & Standar Pengembangan

Proyek ini dipelihara secara teratur dengan alur perbaikan atomik menggunakan format **Semantic Commit**. Setiap perubahan harus menyentuh ruang lingkup tertentu dan didahului oleh awalan penjelas formal:

- `feat:` untuk penambahan fitur, modul layar, atau komponen kemampuan baru.
- `fix:` untuk koreksi cacat logika, pembetulan bug, atau pemulihan stabilitas.
- `refactor:` untuk peremajaan susunan kode tanpa mengubah penulisan keluaran fungsional.
- `docs:` untuk dokumentasi sistem, pembaruan README, atau penandatanganan kemajuan tugas.
- `chore:` untuk pemutakhiran versi paket dependensi, konfigurasi perkakas, atau pemeliharaan repositori.

---

## 8. Lisensi & Hak Kepemilikan

GeoSync merupakan perangkat lunak eksklusif berlisensi yang dibangun untuk kebutuhan manajemen operasional korporat. Seluruh hak atas arsitektur sistem, skema relasi data, serta kekayaan intelektual pengembangan melekat mutlak pada instansi atau pihak pemilik proyek yang berwenang.
