# Task KARYAWAN-001: Absensi Check-In / Check-Out (GPS + Selfie + Offline)

> **Role**: EMPLOYEE (Karyawan)
> **Prasyarat**: `shared/001-foundation-and-auth.md` selesai ✅

## 1. Tujuan Task
Membangun layar utama karyawan beserta seluruh mesin absensi: deteksi geofencing GPS, pengambilan foto *liveness* dari kamera depan, pemblokiran Fake GPS/VPN, dan mekanisme penyimpanan lokal saat sinyal hilang dengan auto-sync ke Supabase saat koneksi kembali.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **K1.1. Employee Home Screen (Layar Utama Karyawan)**
  - Bangun `EmployeeHomeScreen` di `lib/features/attendance/` dengan layout:
    - **Live Digital Clock** real-time (font Monospace, 48px, update setiap detik).
    - **Nama & Greeting**: "Selamat Pagi, Budi 👋" berdasarkan jam aktual.
    - **Mini-Map Box**: Tampilkan titik biru (posisi user) vs lingkaran zona (radius kantor).
      - Warna lingkaran: 🟢 Hijau jika dalam jangkauan, 🔴 Merah jika di luar.
    - **Big Punch Button (diameter 160px)** di tengah layar:
      - State `BELUM ABSEN`: Hijau Emerald `#0D9488`, label "CHECK IN".
      - State `SUDAH MASUK`: Oranye, label "CHECK OUT".
      - State `DI LUAR ZONA`: Abu-abu gelap, disabled, label "DI LUAR ZONA".
    - **Badge Status Hari Ini**: Tampilkan hasil absen terakhir ("Tepat Waktu 08:03" / "Terlambat 08:22").

- [ ] **K1.2. Geofencing Engine & Anti-Mock GPS**
  - Pasang package `geolocator` (akurasi HIGH).
  - Implementasi fungsi `calculateDistance(lat1, lon1, lat2, lon2)` dengan rumus **Haversine**.
  - Stream posisi real-time setiap 5 detik untuk mengupdate status tombol secara live.
  - **Anti-Fake GPS**: Periksa `isFromMockProvider` dari `geolocator`. Jika `true`:
    - Nonaktifkan tombol absen.
    - Tampilkan snackbar error: *"Terdeteksi GPS palsu. Matikan Mock Location untuk absen."*

- [ ] **K1.3. Live Selfie Camera & Upload ke Supabase Storage**
  - Saat tombol ditekan → langsung buka kamera depan (`CameraLensDirection.front`).
  - Kompres foto ke < 500 KB menggunakan `flutter_image_compress`.
  - Upload ke Supabase Storage bucket `attendance-selfies` di path: `/{employee_id}/{date}/{check_in|check_out}.jpg`.
  - Simpan URL publik hasil upload ke kolom `check_in_photo` / `check_out_photo` di tabel `attendance`.
  - Berikan **Haptic Feedback** (`HapticFeedback.mediumImpact()`) saat absensi berhasil tersimpan.

- [ ] **K1.4. Server-Side Timestamp & Simpan ke Database**
  - Jangan gunakan `DateTime.now()` dari HP untuk `check_in_time`.
  - Gunakan PostgreSQL `DEFAULT now()` — waktu diset otomatis oleh server Supabase saat INSERT.
  - Insert baris absensi ke tabel `attendance` dengan payload:
    ```dart
    {
      'employee_id': currentUser.id,
      'check_in_lat': position.latitude,
      'check_in_long': position.longitude,
      'check_in_photo': photoUrl,
      'status': isLate ? 'LATE' : 'ON_TIME',
    }
    ```

- [ ] **K1.5. Offline Mode & Auto-Sync Worker**
  - Gunakan `hive` / `drift` untuk menyimpan log absensi lokal saat `ConnectivityResult.none`.
  - Tambahkan atribut `sync_status: 'PENDING' | 'SYNCED'` di skema lokal.
  - Buat listener `connectivity_plus` yang memicu batch upload saat koneksi kembali:
    1. Upload foto dari local storage ke Supabase Storage.
    2. Insert record ke PostgreSQL dengan URL foto hasil upload.
    3. Update `sync_status` lokal menjadi `'SYNCED'`.

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Tombol absen disabled secara konsisten jika jarak > radius kantor (misal > 50m).
- [ ] Fake GPS / Mock Location terdeteksi dan tombol diblokir sebelum aksi apapun.
- [ ] Foto hanya bisa diambil dari kamera depan — tidak bisa pilih dari galeri.
- [ ] Server timestamp tercatat, bukan jam HP user.
- [ ] Offline mode menyimpan data lokal tanpa crash, dan auto-sync tanpa duplikasi data.
- [ ] Haptic feedback terasa saat check-in/out berhasil.
