// ====================================================================
// GEOSYNC - ADMIN EXPORT REPORTS TAB (PORTAL HRD TAB 4)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../widgets/admin_app_bar.dart';

class ExportHistoryItem {
  final String filename;
  final String timestamp;
  final String size;

  ExportHistoryItem({required this.filename, required this.timestamp, required this.size});
}

class AdminExportTab extends ConsumerStatefulWidget {
  const AdminExportTab({super.key});

  @override
  ConsumerState<AdminExportTab> createState() => _AdminExportTabState();
}

class _AdminExportTabState extends ConsumerState<AdminExportTab> {
  String _selectedMonth = 'Juli 2024';
  String _selectedDepartment = 'Semua Departemen';
  bool _isDownloading = false;

  final List<ExportHistoryItem> _history = [
    ExportHistoryItem(filename: 'Laporan_Juli_2024.xlsx', timestamp: '31 Jul 2024 • 14:30 WIB', size: '2.4 MB'),
    ExportHistoryItem(filename: 'Laporan_Juni_2024.xlsx', timestamp: '30 Jun 2024 • 09:15 WIB', size: '2.1 MB'),
    ExportHistoryItem(filename: 'Laporan_Mei_2024_HR.xlsx', timestamp: '31 Mei 2024 • 16:45 WIB', size: '1.1 MB'),
  ];

  void _triggerDownload() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final cleanMonth = _selectedMonth.replaceAll(' ', '_');
    final deptSuffix = _selectedDepartment == 'Semua Departemen' ? '' : '_${_selectedDepartment.split(' ').first}';
    final newFile = 'Laporan_${cleanMonth}$deptSuffix.xlsx';

    setState(() {
      _isDownloading = false;
      _history.insert(0, ExportHistoryItem(
        filename: newFile,
        timestamp: 'Hari ini • Baru saja',
        size: '2.5 MB',
      ));
    });

    if (mounted) {
      AppToast.show(
        context,
        title: 'Ekspor Berhasil!',
        message: 'File $newFile telah selesai diunduh dan tersedia di penyimpanan Anda.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shared Header
              const AdminAppBar(notificationCount: 3),
              const SizedBox(height: 24),

              // Titles
              const Text('Export Data Laporan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
              const SizedBox(height: 6),
              const Text(
                'Unduh rekapitulasi data kehadiran dan performa\nkaryawan.',
                style: TextStyle(fontSize: 14.5, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Filter Selection Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PERIODE BULAN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderLight, width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMonth,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          items: ['Juli 2024', 'Juni 2024', 'Mei 2024', 'Agustus 2024'].map((m) {
                            return DropdownMenuItem(value: m, child: Text(m));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMonth = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('DEPARTEMEN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderLight, width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDepartment,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          items: ['Semua Departemen', 'IT', 'HR', 'Finance', 'Operations'].map((d) {
                            return DropdownMenuItem(value: d, child: Text(d));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDepartment = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Record Found Pill Indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3F8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppTheme.borderLight, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers_outlined, color: AppTheme.secondaryColor, size: 18),
                      SizedBox(width: 8),
                      Text('Ditemukan 1,250 record', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Download Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isDownloading ? null : _triggerDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isDownloading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, size: 24),
                            SizedBox(width: 10),
                            Text('Download Laporan XLSX', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 36),

              // Riwayat Unduhan Title
              const Text('Riwayat Unduhan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 14),

              // History Cards
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _history.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFEFF3F8), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.description_outlined, color: AppTheme.primaryColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_history[i].filename, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('${_history[i].timestamp} • ${_history[i].size}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      if (i < _history.length - 1)
                        const Divider(height: 1, color: AppTheme.borderLight, indent: 68, endIndent: 18),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lihat Semua Riwayat Link
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Semua Riwayat', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
