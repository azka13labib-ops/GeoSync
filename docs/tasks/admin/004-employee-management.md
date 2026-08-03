# Task ADMIN-004: Manajemen Data Karyawan & Reset Device

> **Role**: ADMIN
> **Prasyarat**: `shared/001-foundation-and-auth.md` selesai ✅

## 1. Tujuan Task
Membangun pusat pengelolaan data master karyawan. Admin dapat mendaftarkan karyawan baru, mengedit data, menonaktifkan akun, dan — paling krusial — mereset binding perangkat (Device Unbind) jika karyawan ganti atau kehilangan HP.

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [ ] **A4.1. Layar Daftar Karyawan (`EmployeeListScreen`)**
  - Buat `EmployeeListScreen` di `lib/features/admin/`.
  - Tampilkan semua karyawan dalam `ListView` dengan card ringkas:
    - Avatar (inisial nama) + Nama Lengkap + NIK.
    - Badge Divisi + badge Role (`EMPLOYEE` / `ADMIN`).
    - Badge Status: 🟢 Aktif / 🔴 Nonaktif (`is_active`).
    - Ikon 🔗 jika `device_id` sudah terikat, atau ikon 🔓 jika belum.
  - **Search Bar** di atas untuk mencari karyawan berdasarkan nama atau NIK.
  - **Filter Dropdown**: Filter berdasarkan Divisi atau Status (Aktif/Nonaktif).
  - **FAB (Floating Action Button)** `+` di pojok kanan bawah → membuka form tambah karyawan.

- [ ] **A4.2. Form Tambah / Edit Karyawan (`EmployeeFormScreen`)**
  - Field form:
    - NIK (unik, wajib).
    - Nama Lengkap (wajib).
    - Email (untuk Supabase Auth akun baru).
    - Password awal (di-generate otomatis atau diisi manual).
    - Dropdown Divisi (dari tabel `departments`).
    - Dropdown Kantor / Geofence (dari tabel `office_locations`).
    - Dropdown Role (`EMPLOYEE` atau `ADMIN`).
    - Sisa Kuota Cuti (`leave_balance`, default: 12).
    - Toggle `is_active`.
  - **Saat Tambah Karyawan Baru**:
    1. Buat akun di Supabase Auth via `supabase.auth.admin.createUser()` (server-side via Edge Function untuk keamanan).
    2. Insert profil ke tabel `employees` dengan `id` = UID yang baru dibuat.
  - **Saat Edit**: Update kolom yang berubah saja (gunakan `upsert` atau `update`).

- [ ] **A4.3. Manajemen Divisi (`DepartmentManagementScreen`)**
  - Layar sederhana untuk CRUD tabel `departments`:
    - List nama divisi yang ada.
    - Tombol tambah divisi baru (`TextField` + `[Simpan]`).
    - Tombol edit & hapus per baris (dengan konfirmasi jika ada karyawan yang terikat).

- [ ] **A4.4. Device Management — Reset / Unbind IMEI**
  - Di dalam detail karyawan, tampilkan section **"Perangkat Terikat"**:
    - Tampilkan UUID perangkat yang tersimpan (atau "Belum terikat" jika `device_id = NULL`).
  - Tombol merah **[Unbind Perangkat]**:
    - Munculkan konfirmasi dialog: *"Apakah kamu yakin ingin melepas ikatan perangkat karyawan ini?"*.
    - Saat dikonfirmasi: set `device_id = NULL` di tabel `employees`.
    - Kirim FCM notifikasi ke karyawan: *"Perangkatmu telah di-reset. Silakan login ulang di perangkat baru."*
  - Catat aksi unbind di **Audit Log** (tabel `audit_logs`) dengan: `who`, `action`, `target_employee_id`, `timestamp`.

- [ ] **A4.5. Tabel Audit Log (Opsional — Sangat Direkomendasikan)**
  - Buat tabel `audit_logs` di Supabase:
    ```sql
    CREATE TABLE public.audit_logs (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      performed_by UUID REFERENCES public.employees(id),
      action VARCHAR(100) NOT NULL, -- contoh: 'UNBIND_DEVICE', 'DEACTIVATE_EMPLOYEE'
      target_employee_id UUID REFERENCES public.employees(id),
      notes TEXT,
      created_at TIMESTAMPTZ DEFAULT now()
    );
    ```
  - Insert log setiap kali Admin melakukan aksi sensitif (unbind device, nonaktifkan karyawan, ubah role).

---

## 3. Kriteria Penerimaan (Definition of Done)
- [ ] Admin dapat menambah karyawan baru dan akun Supabase Auth-nya terbuat secara otomatis.
- [ ] Edit data karyawan tersimpan tanpa mengganggu data absensi yang sudah ada.
- [ ] Tombol Unbind Device berhasil mengosongkan `device_id` dan karyawan dapat login ulang di HP baru.
- [ ] Setiap aksi unbind & deaktivasi tercatat di tabel `audit_logs`.
- [ ] Search dan filter di daftar karyawan berjalan responsif tanpa lag.
