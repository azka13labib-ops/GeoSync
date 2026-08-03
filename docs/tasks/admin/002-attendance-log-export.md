# Task ADMIN-002: Log Absensi & One-Click Excel Export

> **Role**: ADMIN
> **Prasyarat**: `admin/001-dashboard-overview.md` selesai ✅

## 1. Tujuan Task
Membangun pusat data absensi Admin: tabel log kehadiran seluruh karyawan yang dapat difilter secara fleksibel, ditampilkan sebagai kartu responsif di HP, beserta mesin **One-Click Export ke file `.xlsx`** yang siap dipakai untuk payroll — tanpa memerlukan server atau backend tambahan.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **A2.1. Layar Log Absensi (`AttendanceLogScreen`)**
  - Buat `AttendanceLogScreen` di `lib/features/admin/`.
  - **Filter Bar** di bagian atas (atau dalam Bottom Sheet pada layar kecil):
    - 📅 **Date Range Picker**: Pilih rentang tanggal (default: hari ini). Tersedia shortcut: Hari Ini, Minggu Ini, Bulan Ini (MTD).
    - 🏢 **Dropdown Divisi**: Filter berdasarkan departemen (atau "Semua Divisi").
    - 🔴 **Dropdown Status**: Filter berdasarkan `ON_TIME`, `LATE`, atau semua status.
  - Tombol **[Export .xlsx]** berwarna hijau emerald di pojok kanan atas.

- [ ] **A2.2. Tampilan Data Adaptif (Card vs Table)**
  - Gunakan `LayoutBuilder` untuk menentukan mode tampilan berdasarkan lebar layar:
  - **Mode HP (< 600px) → Responsive Cards**:
    - Setiap card berisi:
      - Kiri: Foto selfie melingkar `CircleAvatar` (48px, diambil dari `check_in_photo` URL).
      - Tengah: Nama Karyawan (Bold) + NIK & Divisi (abu-abu 12px).
      - Kanan: Badge status berwarna (`ON_TIME` hijau, `LATE` amber) + jam masuk.
      - Bawah: Jam Keluar (jika ada) + ikon pin lokasi kecil.
  - **Mode Tablet (≥ 600px) → Data Table**:
    - Kolom: No, NIK, Nama, Divisi, Tanggal, Jam Masuk, Jam Keluar, Status.
    - Fitur: sortable column, live search (filter nama/NIK), pagination 20 baris/halaman.

- [ ] **A2.3. One-Click Excel Export Engine**
  - Pasang library `excel: ^4.x` atau `syncfusion_flutter_xlsio` di `pubspec.yaml`.
  - Saat tombol **[Export .xlsx]** ditekan:
    1. Jalankan query Supabase dengan filter yang aktif (menggunakan query dari `docs/database.md` Section 4).
    2. Buat workbook Excel in-memory:
       - **Sheet 1 — Rekap Absensi**: Satu baris per record.
       - Header row: warna background Emerald `#0D9488`, teks Bold & putih.
       - Auto-fit column width.
    3. Simpan file dengan nama otomatis: `GeoSync_Absensi_{divisi}_{startDate}_sd_{endDate}.xlsx`.
    4. Tampilkan opsi berbagi via `share_plus`:
       - 💾 Simpan ke Downloads HP.
       - 📤 Share ke WhatsApp / Email / Drive.
  - Tampilkan `CircularProgressIndicator` selama proses generate berjalan.

- [ ] **A2.4. Detail Absensi Per Karyawan (Modal / Bottom Sheet)**
  - Saat card/row di-tap, tampilkan Bottom Sheet detail lengkap:
    - Foto selfie check-in ukuran besar (200px).
    - Jam masuk & keluar + total jam kerja.
    - Koordinat GPS + tombol "Lihat di Maps".
    - Foto selfie check-out (jika ada).

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Filter tanggal, divisi, dan status bekerja akurat dan mengupdate tampilan secara instan.
- [ ] Tampilan beralih ke card (HP) dan tabel (tablet) sesuai lebar layar.
- [ ] File Excel berhasil di-generate dalam < 3 detik untuk data 500 baris.
- [ ] File Excel memiliki header berwarna, kolom auto-fit, dan data sesuai filter yang dipilih.
- [ ] Opsi Share (WhatsApp/Email/Simpan) muncul setelah file selesai di-generate.
