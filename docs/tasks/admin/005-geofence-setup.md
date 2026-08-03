# Task ADMIN-005: Atur Jam Kerja, Pengaturan Geofence & Polish Final UI/UX

> **Role**: ADMIN
> **Prasyarat**: `admin/001-dashboard-overview.md` selesai ✅

## 1. Tujuan Task
Membangun fitur **pengaturan jam kerja perusahaan** (batas masuk, toleransi terlambat, jam pulang), pengaturan titik koordinat **geofence interaktif** berbasis peta, serta menjalankan tahap akhir *polish* antarmuka — memastikan seluruh aplikasi GeoSync terasa premium, responsif, dan aman sebelum distribusi ke perusahaan klien.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **A5.1. Pengaturan Jam Kerja (`WorkHoursSettingScreen`)**
  - Buat `WorkHoursSettingScreen` di `lib/features/admin/`.
  - Admin dapat mengonfigurasi aturan jam kerja perusahaan:
    - ⏰ **Jam Masuk (Check-In Open)**: Waktu paling awal karyawan bisa absen masuk (misal: `07:00`).
    - ⏰ **Batas Tepat Waktu**: Batas akhir masuk tanpa kena status `LATE` (misal: `08:00`).
    - ⏰ **Toleransi Terlambat**: Menit kelonggaran setelah batas tepat waktu sebelum dinyatakan terlambat (misal: `15 menit` → terlambat jika > `08:15`).
    - ⏰ **Jam Pulang (Check-Out Open)**: Waktu paling awal karyawan bisa absen pulang (misal: `17:00`).
  - Simpan konfigurasi ke tabel `work_hour_settings` di Supabase:
    ```sql
    CREATE TABLE public.work_hour_settings (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      office_location_id UUID REFERENCES public.office_locations(id),
      checkin_open TIME DEFAULT '07:00',
      late_threshold TIME DEFAULT '08:00',
      late_tolerance_minutes INTEGER DEFAULT 15,
      checkout_open TIME DEFAULT '17:00',
      updated_by UUID REFERENCES public.employees(id),
      updated_at TIMESTAMPTZ DEFAULT now()
    );
    ```
  - Konfigurasi ini dikonsumsi oleh `attendance` engine di sisi karyawan untuk menentukan status `ON_TIME` / `LATE`.
  - Tampilkan preview teks: *"Karyawan dinyatakan TERLAMBAT jika absen masuk setelah 08:15"*.

- [ ] **A5.2. Layar Pengaturan Geofence (`GeofenceSetupScreen`)**
  - Buat `GeofenceSetupScreen` di `lib/features/admin/`.
  - Tampilkan daftar lokasi kantor yang ada (dari tabel `office_locations`) dalam bentuk list card.
  - Setiap card menampilkan: Nama Kantor, Koordinat, Radius, dan Jam Kerja yang berlaku.
  - Tombol **[Tambah Lokasi]** dan **[Edit]** per kartu.

- [ ] **A5.3. Peta Interaktif Penentuan Koordinat**
  - Gunakan `flutter_map` (OpenStreetMap, gratis) atau `google_maps_flutter` (butuh API Key).
  - Saat Admin membuka form tambah/edit lokasi:
    - Tampilkan peta layar penuh dengan marker yang bisa di-drag.
    - Sediakan **Search Bar** di atas peta untuk mencari nama kota/jalan (geocoding via nominatim.openstreetmap.org).
    - Gambar lingkaran radius transparan di atas peta yang memperlihatkan area geofence secara visual.
    - **Slider Radius** di bawah peta: range 25 meter – 500 meter. Lingkaran di peta ikut membesar/mengecil secara real-time.
  - Form input tambahan: Nama Lokasi/Kantor Cabang.
  - Tombol **[Simpan Lokasi]** → insert/update ke tabel `office_locations`.

- [ ] **A5.4. Polish UI/UX — Animasi & Micro-Interactions**
  - **Shimmer Loading**: Pastikan semua halaman yang melakukan fetch data (dashboard, log absensi, daftar karyawan) menampilkan skeleton shimmer saat loading.
    - Package: `shimmer: ^3.x`.
  - **Hero Animation**: Saat foto selfie di-tap dari card untuk membesar, gunakan `Hero` widget agar transisi terasa mulus.
  - **Haptic Feedback**: Verifikasi bahwa `HapticFeedback.mediumImpact()` terpanggil di semua aksi penting (check-in berhasil, approve/reject, simpan form).
  - **Empty State**: Setiap layar list harus memiliki tampilan *empty state* yang ramah jika data kosong (ilustrasi sederhana + teks informatif).

- [ ] **A5.5. Security Audit & RLS Verification**
  - Login sebagai akun `EMPLOYEE` dan pastikan:
    - Tidak bisa mengakses endpoint admin (GoRouter guard menolak).
    - Tidak bisa menarik data absensi karyawan lain via Supabase query langsung (RLS memblokir).
    - Tidak bisa mengakses bucket Storage foto karyawan lain.
  - Uji performa **Excel Export** dengan dataset besar:
    - 500 baris → target < 2 detik.
    - 2.000 baris → target < 5 detik.
    - Tambahkan `compute()` (isolate) jika proses generate memblokir UI thread.

- [ ] **A5.6. Edge Case & Error Handling**
  - Semua jaringan error harus ditangani dengan `SnackBar` yang ramah: *"Gagal memuat data. Periksa koneksimu."*
  - Saat Supabase Storage upload gagal (jaringan putus), tampilkan retry button.
  - Pastikan `try-catch` terpasang di semua operasi async kritikal (absen, upload foto, export Excel).

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Admin dapat menyimpan konfigurasi jam masuk, batas tepat waktu, toleransi, dan jam pulang per lokasi kantor.
- [ ] Status `ON_TIME` / `LATE` di tabel absensi dihitung berdasarkan konfigurasi `work_hour_settings`, bukan hardcode.
- [ ] Admin dapat menambah/edit lokasi kantor dengan drag pin di atas peta + slider radius visual.
- [ ] Lingkaran geofence di peta bergerak real-time saat slider digeser.
- [ ] Shimmer loading tampil di semua layar yang melakukan data fetching.
- [ ] Tidak ada kebocoran data antar role yang terdeteksi selama security audit RLS.
- [ ] Excel Export untuk 2.000 baris selesai < 5 detik dan tidak membekukan UI.
- [ ] Semua error ditangani dengan pesan yang jelas dan tidak ada unhandled exception.
