# Task KARYAWAN-002: Pengajuan Ketidakhadiran (Cuti / Sakit / Izin) & Notifikasi FCM

> **Role**: EMPLOYEE (Karyawan) — dan Admin menerima notifikasinya
> **Prasyarat**: `shared/001-foundation-and-auth.md` selesai ✅

## 1. Tujuan Task
Mendigitalisasi seluruh proses pengajuan ketidakhadiran karyawan. Karyawan mengisi form digital dengan validasi ketat, mengupload bukti surat dokter jika sakit, lalu Admin menerima push notification FCM secara instan di HP-nya untuk segera ditindaklanjuti.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **K2.1. Database & RLS — Tabel `leave_requests`**
  - Pastikan tabel `leave_requests` sudah terbuat (dari task `shared/001`).
  - Verifikasi RLS: karyawan hanya bisa `INSERT` dan `SELECT` data miliknya sendiri.
  - Pastikan trigger atau relasi ke `leave_balance` di tabel `employees` siap untuk dikurangi saat disetujui Admin.

- [ ] **K2.2. Form Pengajuan Digital (`LeaveRequestFormScreen`)**
  - Buat layar `LeaveRequestFormScreen` di `lib/features/leave/`.
  - Komponen form:
    - **Dropdown Kategori**: `Cuti Tahunan`, `Sakit`, `Izin Pribadi`.
    - **Date Range Picker**: Pilih Tanggal Mulai & Tanggal Selesai (min: hari ini).
    - **Field Alasan**: `TextFormField` multi-line, wajib diisi.
    - **Attachment Surat Dokter**: Tombol upload foto — **WAJIB (required)** jika kategori = `Sakit`. Jika kategori lain, bersifat opsional.
  - Validasi form sebelum submit:
    - Kategori Sakit + tidak ada lampiran → blokir submit + tampilkan error.
    - Tanggal mulai > tanggal selesai → blokir + error.
    - Sisa `leave_balance` = 0 dan kategori = Cuti → tampilkan warning.

- [ ] **K2.3. Upload Lampiran ke Supabase Storage**
  - Foto surat dokter diupload ke bucket `leave-attachments` di path: `/{employee_id}/{leave_request_id}/surat_dokter.jpg`.
  - Simpan URL publik ke kolom `attachment_url` di tabel `leave_requests`.

- [ ] **K2.4. Integrasi Firebase Cloud Messaging (FCM)**
  - Pasang `firebase_core` dan `firebase_messaging` di `pubspec.yaml`.
  - Simpan token FCM perangkat karyawan & Admin ke kolom `fcm_token` di tabel `employees`.
  - Saat karyawan berhasil submit pengajuan baru (status = `PENDING`):
    - Query semua pengguna dengan `role = 'ADMIN'` untuk mengambil `fcm_token` mereka.
    - Kirim push notification ke semua Admin via Supabase Edge Function atau FCM HTTP API:
      ```json
      {
        "title": "Pengajuan Baru 📋",
        "body": "Budi Santoso mengajukan Cuti Tahunan (3 hari)"
      }
      ```

- [ ] **K2.5. Daftar Status Pengajuan Karyawan**
  - Buat tab/layar `MyLeaveRequestsScreen` yang menampilkan riwayat semua pengajuan milik karyawan.
  - Tampilkan dengan badge status:
    - 🟡 `PENDING` — Menunggu persetujuan Admin.
    - 🟢 `APPROVED` — Disetujui.
    - 🔴 `REJECTED` — Ditolak (tampilkan alasan penolakan jika ada).
  - Karyawan menerima push notification saat status pengajuannya berubah.

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Form tidak bisa disubmit jika kategori Sakit tanpa lampiran foto surat dokter.
- [ ] Foto surat dokter berhasil terupload ke Supabase Storage dan URL tersimpan di database.
- [ ] Segera setelah submit, push notification FCM muncul di HP Admin dalam < 5 detik.
- [ ] Status pengajuan tampil akurat di daftar riwayat karyawan dan terupdate real-time saat Admin mengubahnya.
