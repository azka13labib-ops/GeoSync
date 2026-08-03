# Task SHARED-001: Foundation, Auth Universal & Device Binding

> **Scope**: Shared (berlaku untuk semua role — ADMIN & EMPLOYEE)

## 1. Tujuan Task
Membangun fondasi awal proyek Flutter dan mengonfigurasi skema database di Supabase. Task ini adalah **prasyarat** sebelum task ADMIN maupun KARYAWAN bisa dimulai. Mencakup setup proyek, migrasi DDL database, implementasi login universal, dan mekanisme penguncian perangkat (*Device UUID Binding*).

---

## 2. Rincian Pekerjaan (Sub-Tasks)

- [x] **S1.1. Inisialisasi Proyek Flutter & Folder Structure**
  - Buat proyek Flutter baru dengan target platform Android & iOS.
  - Terapkan folder struktur *Feature-First*: `lib/core/`, `lib/features/`, `lib/navigation/`.
  - Pasang dependensi di `pubspec.yaml`:
    ```yaml
    flutter_riverpod: ^2.x
    supabase_flutter: ^2.x
    go_router: ^13.x
    device_info_plus: ^10.x
    google_fonts: ^6.x
    flutter_secure_storage: ^9.x
    connectivity_plus: ^6.x
    ```

- [x] **S1.2. Supabase Cloud Setup & DDL Migration**
  - Jalankan seluruh DDL SQL dari `docs/database.md` di SQL Editor Supabase secara berurutan:
    1. `departments`
    2. `office_locations`
    3. `employees` (ENUM: `ADMIN | EMPLOYEE`)
    4. `attendance`
    5. `leave_requests`
  - Aktifkan semua kebijakan RLS sesuai `docs/database.md` Section 3.

- [x] **S1.3. Supabase Client & AuthRepository**
  - Buat singleton `SupabaseClient` di `lib/core/network/supabase_client.dart`.
  - Buat `AuthRepository` berbasis Riverpod yang mengekspos:
    - `signInWithNik(nik, password)` → memanggil `supabase.auth.signInWithPassword`
    - `getCurrentEmployee()` → menarik profil + role dari tabel `employees`
    - `signOut()`

- [x] **S1.4. Device UUID Binding Engine**
  - Gunakan `device_info_plus` untuk mengambil UUID unik perangkat (Android: `androidId`, iOS: `identifierForVendor`).
  - Logika binding saat login berhasil:
    - Jika `device_id` di database = `NULL` → simpan UUID perangkat saat ini ke `employees`.
    - Jika `device_id` sudah ada tapi **tidak cocok** dengan UUID perangkat saat ini → tolak sesi & tampilkan error: *"Perangkat tidak dikenali. Hubungi Admin untuk reset."*
  - Simpan UUID lokal di `FlutterSecureStorage` agar tidak perlu re-query setiap buka app.

- [x] **S1.5. Universal Login Screen & Role-Based Router Guard**
  - Buat `LoginScreen` dengan desain *Glassmorphism*: hanya input NIK & Password, tanpa tombol Register.
  - Konfigurasikan `GoRouter` dengan redirect guard:
    ```dart
    // 2 role → 2 rute, sesederhana itu
    if (role == Role.employee) return '/employee/home';
    if (role == Role.admin)    return '/admin/dashboard';
    ```

---

## 3. Kriteria Penerimaan (Definition of Done)
- [x] Proyek dapat di-build untuk Android & iOS tanpa error.
- [x] Login dengan NIK + password berhasil dan mengarahkan ke layar yang tepat sesuai role.
- [x] Login dengan perangkat kedua yang berbeda ditolak secara otomatis oleh Device Binding.
- [x] Semua tabel Supabase terbuat dengan RLS aktif dan terverifikasi via Supabase Dashboard.
