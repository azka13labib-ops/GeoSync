-- ====================================================================
-- GEOSYNC - ENTERPRISE ATTENDANCE SYSTEM DATABASE SCHEMA
-- Migracomplete schema for 2-role system (ADMIN & EMPLOYEE)
-- ====================================================================

-- 1. Ekstensi UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabel Departments (Divisi/Departemen)
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabel Office Locations (Titik Geofencing)
CREATE TABLE IF NOT EXISTS public.office_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    latitude FLOAT8 NOT NULL,
    longitude FLOAT8 NOT NULL,
    radius_meters INTEGER DEFAULT 50 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Tabel Work Hour Settings (Konfigurasi Jam Kerja per Kantor)
CREATE TABLE IF NOT EXISTS public.work_hour_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    office_location_id UUID REFERENCES public.office_locations(id) ON DELETE CASCADE,
    checkin_open TIME DEFAULT '07:00' NOT NULL,
    late_threshold TIME DEFAULT '08:00' NOT NULL,
    late_tolerance_minutes INTEGER DEFAULT 15 NOT NULL,
    checkout_open TIME DEFAULT '17:00' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Tabel Employees (Profil Karyawan - Berelasi ke Supabase auth.users)
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('ADMIN', 'EMPLOYEE');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS public.employees (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nik VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'EMPLOYEE'::user_role NOT NULL,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    office_location_id UUID REFERENCES public.office_locations(id) ON DELETE SET NULL,
    device_id VARCHAR(255), -- Menyimpan UUID Hardware HP untuk penguncian device binding
    fcm_token TEXT, -- Token Firebase Cloud Messaging untuk push notification
    leave_balance INTEGER DEFAULT 12 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Tabel Attendance (Log Absensi Harian)
DO $$ BEGIN
    CREATE TYPE attendance_status AS ENUM ('ON_TIME', 'LATE');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    check_in_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    check_out_time TIMESTAMPTZ,
    status attendance_status DEFAULT 'ON_TIME'::attendance_status NOT NULL,
    check_in_lat FLOAT8 NOT NULL,
    check_in_long FLOAT8 NOT NULL,
    check_out_lat FLOAT8,
    check_out_long FLOAT8,
    check_in_photo TEXT NOT NULL, -- URL gambar selfie dari Supabase Storage
    check_out_photo TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_employee_daily_attendance UNIQUE (employee_id, date)
);

-- 7. Tabel Leave Requests (Pengajuan Cuti / Sakit / Izin)
DO $$ BEGIN
    CREATE TYPE leave_type AS ENUM ('SICK', 'LEAVE', 'PERMISSION');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE approval_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS public.leave_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
    type leave_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    attachment_url TEXT, -- Wajib bila type = 'SICK' (Bukti foto surat dokter)
    status approval_status DEFAULT 'PENDING'::approval_status NOT NULL,
    rejection_reason TEXT,
    approved_by UUID REFERENCES public.employees(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Tabel Audit Logs (Catatan Jejak Audit Aktivitas Admin)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    performed_by UUID REFERENCES public.employees(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- contoh: 'UNBIND_DEVICE', 'DEACTIVATE_EMPLOYEE'
    target_employee_id UUID REFERENCES public.employees(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ====================================================================
-- INDEX OPTIMASI PERFORMA QUERY
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_attendance_employee_date ON public.attendance(employee_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON public.attendance(date);
CREATE INDEX IF NOT EXISTS idx_employees_department ON public.employees(department_id);
CREATE INDEX IF NOT EXISTS idx_employees_role ON public.employees(role);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON public.leave_requests(status);

-- ====================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.office_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_hour_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Master data (Departments & Locations) dapat dibaca semua user login, dikelola Admin
CREATE POLICY "Anyone logged in can read departments" ON public.departments
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin can manage departments" ON public.departments
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

CREATE POLICY "Anyone logged in can read office locations" ON public.office_locations
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin can manage office locations" ON public.office_locations
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

CREATE POLICY "Anyone logged in can read work hours" ON public.work_hour_settings
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin can manage work hours" ON public.work_hour_settings
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

-- 1. RLS untuk Tabel Employees
CREATE POLICY "Employees can read own profile" ON public.employees
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admin can manage all profiles" ON public.employees
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

-- 2. RLS untuk Tabel Attendance
CREATE POLICY "Employees insert their own attendance" ON public.attendance
    FOR INSERT WITH CHECK (auth.uid() = employee_id);
CREATE POLICY "Employees read own attendance" ON public.attendance
    FOR SELECT USING (auth.uid() = employee_id);
CREATE POLICY "Admin manage all attendance" ON public.attendance
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

-- 3. RLS untuk Tabel Leave Requests
CREATE POLICY "Employees manage own leave requests" ON public.leave_requests
    FOR ALL USING (auth.uid() = employee_id);
CREATE POLICY "Admin manage all leave requests" ON public.leave_requests
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));

-- 4. RLS untuk Audit Logs (Hanya Admin)
CREATE POLICY "Admin manage audit logs" ON public.audit_logs
    FOR ALL USING (EXISTS (SELECT 1 FROM public.employees WHERE id = auth.uid() AND role = 'ADMIN'));
