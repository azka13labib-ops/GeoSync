# Design System & UI/UX Guidelines
# GeoSync UI – Premium Executive & Glassmorphism Experience

---

## 1. Filosofi & Estetika Visual
Desain antarmuka **GeoSync** menyeimbangkan dua spektrum pengguna utama: **Karyawan (EMPLOYEE)** yang menuntut kecepatan interaksi tanpa hambatan (*Zero Friction* – klik cepat di lapangan), dan **Admin** yang membutuhkan kejelasan visual dan kemudahan membaca data absensi untuk keperluan pengelolaan dan ekspor.

*   **Tema Kunci**: *Modern Professional*, perpaduan *Clean Executive Utility* dengan sentuhan *Glassmorphism* (efek kaca blur berlapis yang memberi kedalaman modern tanpa mendistraksi fungsionalitas).
*   **Aset Animasi & Mikro-Interaksi**:
    *   *Shimmer Loader*: Efek pergerakan cahaya ke perak-perakan pada blok antarmuka saat proses pengambilan GPS atau load data absen.
    *   *Haptic Pulse*: Getaran haptik responsif pada perangkat HP saat tombol "Check-In" berhasil diakses atau saat selfie teregistrasi.

---

## 2. Palet Warna Resmi (Color Tokens)

Warna dirancang khusus dengan kontras tinggi untuk memudahkan pembacaan di bawah sinar matahari langsung (bagi karyawan lapangan) dan tidak membuat mata HRD cepat lelas di layar desktop.

| Token Nama | Kode HEX | Nilai RGB / HSL | Pemakaian Utama |
| :--- | :--- | :--- | :--- |
| **Primary Emerald Teal** | `#0D9488` | `rgb(13, 148, 136)` | Tombol utama Check-In, identitas merek, header aktif. |
| **Primary Darker Teal** | `#115E59` | `rgb(17, 94, 89)` | Efek hover tombol, status bar border pada mode gelap. |
| **Action Sapphire Blue**| `#2563EB` | `rgb(37, 99, 235)` | Tombol ekspor Excel, link, dan opsi administratif HRD. |
| **Success On-Time Green**| `#10B981` | `rgb(16, 185, 129)` | Badge status "Tepat Waktu", lingkaran indikator Geofence valid. |
| **Warning Late Amber** | `#F59E0B` | `rgb(245, 158, 11)` | Badge status "Terlambat", peringatan jam masuk melebihi toleransi. |
| **Danger Alpha Red**   | `#EF4444` | `rgb(239, 68, 68)`  | Tombol Check-Out, indikator "Di Luar Radius GPS", status Alpha. |
| **Neutral Dark Slate** | `#0F172A` | `rgb(15, 23, 42)`  | Latar belakang utama (Background) pada mode gelap & teks utama. |
| **Neutral Light Pearl**| `#F8FAFC` | `rgb(248, 250, 252)`| Latar belakang utama pada mode terang & permukaan kartu. |

---

## 3. Tipografi (Typography)

Menggunakan keluarga font Google Fonts **Inter** atau **Outfit** yang tersertifikasi sangat tajam saat menampilkan angka desimal jam, koordinat GPS, maupun tabel pelat data personalia.

```
Header 1 (Dashboard Title)  : 28px - Bold (800) - Leading 36px - Tracking -0.5px
Header 2 (Card Header)      : 20px - SemiBold (600) - Leading 28px
Body 1 (Table & Data Text)   : 14px - Regular / Medium - Leading 20px
Body 2 (Captions & GPS Info): 12px - Regular (400) - Color Tone 60%
Display Clock (Live Timer)  : 48px - Black (900) - Monolith Spacing for zero-jitter
```

---

## 4. Komponen Spesifik (Component Library)

### 4.1. Glassmorphism Card (Panel Statistik & Info Dashboard)
Komponen kartu tidak menggunakan warna padat yang mendatar, melainkan efek kristal modern:
```css
/* Konsep CSS untuk implementasi BoxDecoration di Flutter */
background: rgba(255, 255, 255, 0.08);
backdrop-filter: blur(16px);
-webkit-backdrop-filter: blur(16px);
border: 1px solid rgba(255, 255, 255, 0.18);
border-radius: 20px;
box-shadow: 0 8px 32px 0 rgba(15, 23, 42, 0.15);
```

### 4.2. Tombol Raksasa Biometrik (Big Punch Button)
Tombol absensi di Beranda Karyawan memiliki diameter minimal **160px**, melingkar di tengah layar dengan animasi gelombang pendar (Ripple effect) untuk memancing refleks klik instan.
*   **State Idle / Dalam Radius**: Lingkaran Hijau Emerald bersinar + Label "CHECK-IN" kapital tebal + Ikon Kamera/Sidik Jari di tengah.
*   **State Di Luar Radius**: Lingkaran Abu-abu gelap dengan batas Merah + Label "DI LUAR ZONA" (Disabled / Tidak bisa dikanan-kiri).
*   **State Sesudah Masuk**: Lingkaran Oranye kemerahan + Label "CHECK-OUT".

---

## 5. Strategi Responsivitas Lintas Layar (Adaptive Layouts)

Sistem merespons lebar viewport perangkat (`MediaQuery.of(context).size.width`) dengan ambang batas (*breakpoint*) cerdas:

```
[< 600px : Smartphone Mode]          [600 - 1024px : Tablet/iPad]
  └─ Employee: Big Punch Button View   └─ Split Screen View
  └─ Card-based Attendance Logs        └─ Side Nav + Responsive Cards
  └─ Bottom Sheet Filters              └─ Inline Modal Filters & Full Tables
  └─ Admin: Card-based Data View       └─ Admin: Sortable Table + Excel Button
```

> **Catatan**: GeoSync adalah **aplikasi mobile**. Tidak ada target layar Desktop PC terpisah. Breakpoint Tablet (600-1024px) ditujukan untuk penggunaan Admin di iPad atau perangkat Android tablet.

### 5.1. Adaptasi Tabel Absensi pada Layar Smartphone (Anti-Clutter)
Jika Admin memantau daftar absensi lewat layar HP (< 600px), tabel bergaris kaku yang mengharuskan *scroll horisontal* **ditiadakan**. Sebagai gantinya, tabel diubah otomatis menjadi deretan **Responsive Cards**:

*   **Isi Kartu (Card Item)**:
    *   *Kiri*: Foto selfie melingkar ukuran 48x48px.
    *   *Tengah*: Nama Karyawan (Bold 14px) + NIK & Divisi (12px abu-abu).
    *   *Kanan Atas*: Badge warna (Hijau untuk "07:58 Tepat Waktu", Merah untuk "08:24 Terlambat").
    *   *Bawah*: Ikon kecil penunjuk lokasi pin kantor tempat absen tercantum.
*   **Menu Filter pada HP**: Menggeser tampilan pemilih rentang waktu (Date Picker) & Divisi dari header horisontal ke dalam **Bottom Sheet** yang meluncur manis dari bagian bawah layar.
