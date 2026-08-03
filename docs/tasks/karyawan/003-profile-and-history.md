# Task KARYAWAN-003: Profil Karyawan & Riwayat Absensi

> **Role**: EMPLOYEE (Karyawan)
> **Prasyarat**: `karyawan/001-attendance-checkin-out.md` selesai ✅

## 1. Tujuan Task
Membangun layar profil dan riwayat absensi karyawan. Karyawan dapat melihat identitasnya, memantau riwayat kehadiran bulanan dalam format kalender berindikator warna, dan mengecek sisa kuota cuti tahunan yang tersisa.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **K3.1. Layar Profil Karyawan (`ProfileScreen`)**
  - Buat `ProfileScreen` di `lib/features/profile/`.
  - Tampilkan data dari tabel `employees`:
    - Foto avatar (inisial nama jika belum ada foto profil).
    - Nama Lengkap & NIK.
    - Divisi / Departemen.
    - Status Perangkat: *"Terikat di perangkat ini"* atau badge peringatan jika UUID tidak cocok.
    - **Sisa Kuota Cuti**: Tampilkan sebagai progress bar atau teks besar, contoh: `"Sisa Cuti: 8 / 12 hari"`.
  - Tombol **Keluar (Sign Out)** di bagian bawah — redirect ke `LoginScreen`.

- [ ] **K3.2. Kalender Riwayat Absensi (`AttendanceHistoryScreen`)**
  - Buat `AttendanceHistoryScreen` di `lib/features/profile/`.
  - Gunakan package `table_calendar` untuk menampilkan kalender bulanan.
  - Tandai setiap tanggal dengan indikator warna berdasarkan status:
    - 🟢 **Hijau** → `ON_TIME` (Tepat Waktu).
    - 🟡 **Kuning/Amber** → `LATE` (Terlambat).
    - 🔵 **Biru** → `APPROVED` leave (Cuti/Sakit/Izin disetujui).
    - 🔴 **Merah** → Tidak hadir / Alpha (tidak ada record attendance & tidak ada approved leave).
    - ⚪ **Abu-abu** → Hari libur / weekend (tidak dihitung).
  - Saat tanggal di-tap, tampilkan **Bottom Sheet detail** berisi:
    - Jam Check-In & Check-Out.
    - Status (Tepat Waktu / Terlambat).
    - Foto Selfie kecil (thumbnail 80px).
    - Koordinat GPS lokasi absen.

- [ ] **K3.3. List View Riwayat (Alternatif Kalender)**
  - Di bawah kalender, tampilkan list card riwayat 30 hari terakhir secara kronologis terbalik.
  - Setiap card menampilkan: tanggal, jam masuk-keluar, status badge, dan ikon kamera kecil jika foto tersedia.
  - Tambahkan tombol toggle "Kalender / List" untuk memilih mode tampilan.

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Profil menampilkan data karyawan yang akurat dari Supabase.
- [ ] Sisa kuota cuti terupdate secara real-time setelah Admin menyetujui cuti.
- [ ] Kalender menampilkan warna yang akurat di setiap tanggal sesuai data attendance & leave.
- [ ] Bottom Sheet detail muncul saat tanggal di-tap dengan info lengkap.
- [ ] Tombol Sign Out berhasil menghapus sesi dan mengarahkan ke LoginScreen.
