// ====================================================================
// GEOSYNC - UNIVERSAL CORPORATE LOGIN SCREEN (CLEAN LIGHT MODE)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authControllerProvider.notifier).signIn(
      _nikController.text.trim(),
      _passwordController.text,
    );

    if (!success && mounted) {
      final errorMsg = ref.read(authControllerProvider).errorMessage ?? 'Login gagal. Periksa NIK dan password Anda.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMsg, style: const TextStyle(color: Colors.white))),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppTheme.primaryColor, size: 28),
            SizedBox(width: 12),
            Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Demi keamanan protokol korporasi, reset kata sandi hanya dapat dieksekusi oleh tim HRD atau Admin IT perusahaan Anda.\n\nSilakan hubungi administrator kantor untuk meminta kredensial baru.',
          style: TextStyle(height: 1.5, color: AppTheme.textPrimary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleBiometricClick() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(child: Text('Biometrik akan aktif secara otomatis setelah Anda berhasil login perdana menggunakan NIK & Password.')),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Dot Matrix Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: const DotPatternPainter(
                dotColor: Color(0xFFCBD5E1),
                spacing: 26,
                radius: 1.3,
              ),
            ),
          ),
          
          // Main Scrollable Form Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Logo Icon Box (Opsi 1 - Cut without text)
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: AppTheme.borderLight, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo_icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.language_rounded,
                            size: 46,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Brand Typography & Subtitle
                    const Text(
                      'GeoSync',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Employee Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Secure attendance tracking for modern teams',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Corporate Clean White Login Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight, width: 1.2),
                        boxShadow: AppTheme.softCardShadow,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // NIK / Corporate ID Field Label
                            const Text(
                              'NIK / Corporate ID',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nikController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Contoh: 11111 atau 12345',
                                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textSecondary),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'NIK Corporate ID wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Label + Forgot Password Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                InkWell(
                                  onTap: _showForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Authenticate Button (Navy Blue)
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleLogin,
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.8),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Authenticate',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.login_rounded, size: 20),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Soft Mint Security Protocols Notice Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.mintAlertBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.mintAlertText.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined, color: AppTheme.mintAlertText, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Location will be verified after login to align with corporate security protocols.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppTheme.mintAlertText,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // "OR" Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppTheme.borderLight, thickness: 1.2)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppTheme.borderLight, thickness: 1.2)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login with Biometrics Button (White Outlined Card Style)
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _handleBiometricClick,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.fingerprint_rounded, size: 24, color: AppTheme.textPrimary),
                                    SizedBox(width: 10),
                                    Text(
                                      'Login with Biometrics',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Footer Links & Version
                    const Text(
                      'Privacy Policy   •   Support',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
