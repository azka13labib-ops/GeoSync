// @ts-nocheck - Deno runtime syntax is executed directly by Deno & Supabase CLI
// ====================================================================
// GEOSYNC EDGE FUNCTION: create-employee
// Deno & TypeScript secure execution for Admin to create Employee accounts
// ====================================================================
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // 1. Handle CORS Preflight request for mobile/client
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error('Server environmental variables missing.');
    }

    // 2. Klien Reguler (Menggunakan Token Auth Admin dari Header Request)
    const authorizationHeader = req.headers.get('Authorization');
    if (!authorizationHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authorizationHeader } },
    });

    // Verifikasi apakah pengguna yang memanggil fungsi ini terautentikasi
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized user credentials' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 3. Verifikasi apakah User ini adalah berstatus 'ADMIN' di tabel employees
    const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
    const { data: employeeRecord, error: roleError } = await adminClient
      .from('employees')
      .select('role')
      .eq('id', user.id)
      .single();

    if (roleError || !employeeRecord || employeeRecord.role !== 'ADMIN') {
      return new Response(JSON.stringify({ error: 'Forbidden: Hanya Admin yang dapat mendaftarkan akun karyawan.' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 4. Baca Payload dari Request (NIK, Password, Nama Lengkap, Divisi, Kantor)
    const { nik, password, full_name, role, department_id, office_location_id, leave_balance } = await req.json();

    if (!nik || !password || !full_name) {
      return new Response(JSON.stringify({ error: 'NIK, Password, dan Nama Lengkap wajib diisi.' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Gunakan email sintetis berdasarkan NIK agar konsisten dengan standar Auth Supabase
    // Contoh: 320123456789@geosync.corp
    const syntheticEmail = `${nik}@geosync.corp`;
    const targetRole = role === 'ADMIN' ? 'ADMIN' : 'EMPLOYEE';

    // 5. Daftarkan User baru menggunakan Admin Service Role (Tanpa logout sesi Admin)
    const { data: newAuthUser, error: createUserError } = await adminClient.auth.admin.createUser({
      email: syntheticEmail,
      password: password,
      email_confirm: true,
      user_metadata: { nik, full_name, role: targetRole },
    });

    if (createUserError || !newAuthUser.user) {
      return new Response(JSON.stringify({ error: `Gagal mendaftarkan ke Auth: ${createUserError?.message}` }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 6. Catat profil Karyawan di Tabel public.employees
    const { data: newEmployee, error: insertError } = await adminClient
      .from('employees')
      .insert({
        id: newAuthUser.user.id,
        nik: nik,
        full_name: full_name,
        role: targetRole,
        department_id: department_id || null,
        office_location_id: office_location_id || null,
        leave_balance: leave_balance ?? 12,
        is_active: true,
      })
      .select()
      .single();

    if (insertError) {
      // Rollback: jika gagal catat di tabel employees, hapus akun auth agar bersih
      await adminClient.auth.admin.deleteUser(newAuthUser.user.id);
      return new Response(JSON.stringify({ error: `Gagal mencatat data karyawan: ${insertError.message}` }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 7. Kembalikan respons berhasil
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Akun karyawan baru berhasil didaftarkan secara aman.',
        employee: newEmployee,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message || 'Terjadi kesalahan internal pada Edge Function.' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
