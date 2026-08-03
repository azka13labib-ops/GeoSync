# Task ADMIN-001: Dashboard Overview (Statistik Real-Time Harian)

> **Role**: ADMIN
> **Prasyarat**: `shared/001-foundation-and-auth.md` selesai ✅

## 1. Tujuan Task
Membangun halaman pertama yang dilihat Admin saat membuka aplikasi: sebuah dashboard ikhtisar harian bergaya *Glassmorphism* yang menampilkan statistik kehadiran real-time seluruh karyawan dalam format kartu visual yang elegan dan informatif.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **A1.1. Admin Dashboard Screen (`AdminDashboardScreen`)**
  - Buat `AdminDashboardScreen` di `lib/features/admin/`.
  - Layout utama menggunakan `Column` + `GridView` untuk menempatkan kartu statistik.
  - Header: Tanggal hari ini + Nama Admin yang login.
  - **Bottom Navigation Bar** dengan 4 tab untuk Admin:
    - 📊 Dashboard (halaman ini)
    - 📋 Log Absensi (→ `admin/002`)
    - ✅ Approval (→ `admin/003`)
    - ⚙️ Kelola (→ `admin/004` & `admin/005`)

- [ ] **A1.2. 4 Kartu Statistik Real-Time (Glassmorphism)**
  - Setiap kartu menggunakan `BoxDecoration` dengan efek glassmorphism:
    ```dart
    BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.18)),
      boxShadow: [BoxShadow(blurRadius: 32, color: Colors.black12)],
    )
    // + BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16))
    ```
  - 4 kartu yang ditampilkan (di-query dengan `Stream` Supabase agar live update):
    1. 🟢 **Total Hadir** — karyawan yang sudah check-in hari ini.
    2. 🟡 **Terlambat** — karyawan dengan status `LATE` hari ini.
    3. 🔵 **Cuti / Sakit / Izin** — karyawan dengan approved leave hari ini.
    4. 🔴 **Alpha** — karyawan aktif yang tidak hadir & tidak ada izin (dihitung dari selisih).
  - Angka di setiap kartu menggunakan `StreamBuilder` agar otomatis refresh tanpa reload.

- [ ] **A1.3. Grafik Tren Kehadiran Mingguan**
  - Tambahkan chart batang (bar chart) menggunakan `fl_chart` di bawah kartu statistik.
  - Tampilkan tren 7 hari terakhir: sumbu X = hari, sumbu Y = jumlah karyawan hadir.
  - Warna bar: Hijau Emerald untuk hadir, Merah untuk absen/alpha.

- [ ] **A1.4. Shimmer Loading State**
  - Saat data sedang diambil dari Supabase, tampilkan skeleton shimmer menggunakan package `shimmer`.
  - Shimmer berbentuk kartu abu-abu bergerak di posisi yang sama dengan kartu statistik asli.

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Kartu statistik menampilkan angka yang akurat dan terupdate secara real-time (uji dengan check-in dari akun karyawan sambil dashboard terbuka).
- [ ] Efek glassmorphism tampil smooth tanpa lag di HP dengan spesifikasi mid-range.
- [ ] Grafik tren mingguan tampil dengan data 7 hari terakhir yang benar.
- [ ] Shimmer loading muncul saat pertama kali halaman dibuka dan data belum tiba.
- [ ] Bottom Navigation Bar berfungsi dan berpindah antar tab dengan benar.
