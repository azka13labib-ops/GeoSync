# Task ADMIN-003: Panel Approval Cuti / Sakit / Izin

> **Role**: ADMIN
> **Prasyarat**: `karyawan/002-leave-request-form.md` selesai ✅

## 1. Tujuan Task
Membangun panel approval ketidakhadiran khusus Admin. Admin menerima push notification FCM saat ada pengajuan baru, lalu dapat menyetujui atau menolak langsung dari aplikasi dengan satu tap. Saat disetujui, sisa kuota cuti karyawan otomatis berkurang di database.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **A3.1. Layar Approval Center (`ApprovalCenterScreen`)**
  - Buat `ApprovalCenterScreen` di `lib/features/leave/`.
  - Tampilkan daftar semua `leave_requests` yang relevan, dibagi menjadi 2 tab:
    - 🟡 **Menunggu (Pending)**: Pengajuan belum diproses, urutkan dari terbaru.
    - 📁 **Riwayat**: Pengajuan yang sudah di-Approve atau Reject.
  - Tampilkan badge jumlah pada tab "Menunggu" di Bottom Navigation Bar Admin jika ada item pending.

- [ ] **A3.2. Card Pengajuan (Leave Request Card)**
  - Setiap pengajuan tampil sebagai card dengan informasi:
    - Avatar + Nama Karyawan + NIK + Divisi.
    - Kategori: badge warna (`Cuti` biru, `Sakit` merah, `Izin` abu-abu).
    - Rentang Tanggal: "01 Agu 2026 – 03 Agu 2026 (3 hari)".
    - Alasan pengajuan (truncate 2 baris, expandable).
    - 📎 Jika ada lampiran surat dokter → tampilkan thumbnail foto yang bisa di-tap untuk melihat full-screen (tanpa harus download).
  - Di bagian bawah card, dua tombol:
    - ✅ **[Setujui]** → warna Hijau Emerald.
    - ❌ **[Tolak]** → warna Merah, memunculkan dialog input alasan penolakan.

- [ ] **A3.3. Logika Approve**
  - Saat Admin tap **[Setujui]**:
    1. Update `status` di `leave_requests` menjadi `'APPROVED'` dan isi `approved_by` dengan `id` Admin.
    2. Hitung durasi (`end_date - start_date + 1 hari`).
    3. Jika kategori = `'LEAVE'` (Cuti Tahunan): kurangi `leave_balance` karyawan sebesar durasi.
       - Pastikan `leave_balance` tidak menjadi negatif (tambahkan validasi).
    4. Kirim FCM push notification ke karyawan: *"Pengajuan cutimu telah disetujui ✅"*.
    5. Refresh daftar — kartu dipindahkan ke tab "Riwayat".

- [ ] **A3.4. Logika Reject**
  - Saat Admin tap **[Tolak]**:
    1. Munculkan `AlertDialog` dengan `TextField` untuk alasan penolakan.
    2. Update `status` di `leave_requests` menjadi `'REJECTED'` + simpan alasan di kolom `rejection_reason` (tambahkan kolom ini di tabel jika belum ada).
    3. Kirim FCM push notification ke karyawan: *"Pengajuanmu ditolak. Alasan: [alasan]"*.
    4. Refresh daftar.

- [ ] **A3.5. FCM untuk Admin (Menerima Notifikasi Baru)**
  - Konfigurasikan handler FCM di `main.dart` untuk:
    - **Foreground**: Tampilkan `SnackBar` atau local notification.
    - **Background / Terminated**: Saat notifikasi di-tap, langsung buka `ApprovalCenterScreen`.

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Daftar pengajuan pending tampil akurat dan terupdate real-time.
- [ ] Foto surat dokter dapat dilihat full-screen tanpa perlu download manual.
- [ ] Saat disetujui, `leave_balance` karyawan berkurang secara akurat di database.
- [ ] Saat ditolak, alasan penolakan tersimpan dan karyawan menerima notifikasi.
- [ ] Karyawan menerima FCM push notification untuk Approve maupun Reject dalam < 10 detik.
- [ ] Badge counter di tab "Menunggu" menunjukkan jumlah yang akurat.
