// ====================================================================
// GEOSYNC - ADMIN OVERTIME & PAYROLL INTEGRATION TAB (PORTAL HRD TAB 4)
// Manajemen Pengajuan Lembur, Approval, Kalkulator UU & Analytics
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../overtime/models/overtime_request.dart';
import '../../controllers/overtime_controller.dart';
import '../../widgets/admin_app_bar.dart';

class AdminOvertimeTab extends ConsumerStatefulWidget {
  const AdminOvertimeTab({super.key});

  @override
  ConsumerState<AdminOvertimeTab> createState() => _AdminOvertimeTabState();
}

class _AdminOvertimeTabState extends ConsumerState<AdminOvertimeTab> {
  int _selectedTabIndex = 0; // 0: Pending Approval, 1: Riwayat, 2: Analisis Payroll & Compliance
  String _historyFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final overtimeList = ref.watch(overtimeControllerProvider);
    final pendingList = overtimeList.where((e) => e.status == 'Pending').toList();
    
    List<OvertimeRequestItem> historyList = overtimeList.where((e) => e.status != 'Pending').toList();
    if (_historyFilter != 'Semua') {
      historyList = historyList.where((e) => e.status == _historyFilter).toList();
    }

    // Perhitungan Payroll
    final totalApprovedHours = overtimeList.where((e) => e.status == 'Disetujui').fold(0.0, (sum, item) => sum + item.durationHours);
    final totalPayrollExpense = overtimeList.where((e) => e.status == 'Disetujui' && e.compensationType == 'Uang Lembur (Rate UU)').fold(0.0, (sum, item) => sum + item.calculatedCompensation);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: AdminAppBar(),
            ),
            
            // Title & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manajemen Lembur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                        SizedBox(height: 4),
                        Text('Approval jam kerja ekstra & terintegrasi payroll UU Ciptaker', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddOvertimeModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.tealButton,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Catat Manual', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Segmented Navigation Tabs (Pill style)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildSegmentTab(0, 'Menunggu (${pendingList.length})'),
                  _buildSegmentTab(1, 'Riwayat'),
                  _buildSegmentTab(2, 'Analitik & Regulasi'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: _selectedTabIndex == 0
                    ? _buildPendingSection(pendingList)
                    : _selectedTabIndex == 1
                        ? _buildHistorySection(historyList)
                        : _buildAnalyticsSection(totalApprovedHours, totalPayrollExpense, currencyFormat, overtimeList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // SUB-TAB 1: PENDING APPROVAL SECTION
  // ====================================================================
  Widget _buildPendingSection(List<OvertimeRequestItem> pendingList) {
    if (pendingList.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 60),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.verified_outlined, size: 64, color: AppTheme.secondaryColor.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            const Text('Seluruh Pengajuan Telah Diproses!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
            const SizedBox(height: 6),
            const Text('Tidak ada antrean pengajuan lembur yang menunggu approval.', style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: pendingList.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: item.isExceedingWeeklyLimit ? AppTheme.errorColor.withValues(alpha: 0.5) : AppTheme.borderLight, width: item.isExceedingWeeklyLimit ? 1.5 : 1.2),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee info header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: item.avatarBg,
                    child: Text(
                      item.employeeName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.employeeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                        const SizedBox(height: 2),
                        Text('${item.department} • NIK: ${item.nik}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                    child: const Text('PENDING', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 14),

              // Time & duration grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailBox(Icons.calendar_today_rounded, 'Tanggal', item.date),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailBox(Icons.schedule_rounded, 'Jam Lembur', '${item.startTime} - ${item.endTime} (${item.durationHours} Jam)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Compensation & Labor Law calculation badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(item.compensationType.contains('Cuti') ? Icons.beach_access_rounded : Icons.payments_rounded, color: const Color(0xFF4F46E5), size: 20),
                        const SizedBox(width: 8),
                        Text(item.compensationType.contains('Cuti') ? 'Kompensasi Cuti' : 'Est. Payroll (UU Ciptaker)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF3730A3))),
                      ],
                    ),
                    Text(
                      item.formattedCompensation,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF312E81)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Reason
              const Text('Alasan Pengajuan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text('"${item.reason}"', style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, color: AppTheme.primaryColor, height: 1.3)),
              const SizedBox(height: 16),

              // Regulatory Compliance warning if hours > 14
              if (item.isExceedingWeeklyLimit) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.badgeRedBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.4))),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Peringatan Regulasi: Pengajuan ini membuat akumulasi lembur minggu ini menembus 14 jam (Batas UU Ketenagakerjaan).',
                          style: TextStyle(fontSize: 12, color: AppTheme.errorColor, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Actions: Approve / Reject / Switch Compensation
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _handleApproval(item, 'Ditolak'),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () => _handleApproval(item, 'Disetujui'),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Setujui Lembur', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderLight)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.tealButton),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // SUB-TAB 2: HISTORY SECTION
  // ====================================================================
  Widget _buildHistorySection(List<OvertimeRequestItem> historyList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'Disetujui', 'Ditolak'].map((filter) {
              final isSelected = _historyFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
                  selected: isSelected,
                  selectedColor: AppTheme.tealButton,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppTheme.tealButton : AppTheme.borderLight)),
                  onSelected: (selected) => setState(() => _historyFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (historyList.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 50),
            alignment: Alignment.center,
            child: const Text('Belum ada riwayat lembur pada filter ini.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          )
        else
          Column(
            children: historyList.map((item) {
              final isApproved = item.status == 'Disetujui';
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.borderLight), boxShadow: AppTheme.softCardShadow),
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: item.avatarBg, child: Text(item.employeeName.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.employeeName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryColor)),
                          Text('${item.date} • ${item.durationHours} Jam', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
                          Text('Kompensasi: ${item.formattedCompensation}', style: TextStyle(color: isApproved ? AppTheme.tealButton : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: isApproved ? AppTheme.mintAlertBg : AppTheme.badgeRedBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(item.status.toUpperCase(), style: TextStyle(color: isApproved ? AppTheme.secondaryColor : AppTheme.errorColor, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ====================================================================
  // SUB-TAB 3: ANALYTICS & REGULATORY COMPLIANCE SECTION
  // ====================================================================
  Widget _buildAnalyticsSection(double totalHours, double totalExpense, NumberFormat currencyFormat, List<OvertimeRequestItem> allItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Summary Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softCardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.timer_rounded, color: AppTheme.tealButton, size: 24),
                    const SizedBox(height: 12),
                    const Text('TOTAL JAM LEMBUR (DISETUJUI)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text('${totalHours.toStringAsFixed(1)} Jam', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softCardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 24),
                    const SizedBox(height: 12),
                    const Text('ESTIMASI PAYROLL (RATE UU)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(totalExpense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Compliance Monitor section
        const Text('Pantauan Kepatuhan Regulasi (Maks 14 Jam / Minggu)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        const SizedBox(height: 4),
        const Text('Memastikan jam kerja tim tidak melanggar ketentuan UU Ketenagakerjaan RI.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.borderLight), boxShadow: AppTheme.softCardShadow),
          child: Column(
            children: allItems.take(5).map((emp) {
              final progress = (emp.weeklyAccumulatedHours / 14.0).clamp(0.0, 1.0);
              final isOver = emp.weeklyAccumulatedHours >= 14.0;
              final isWarning = emp.weeklyAccumulatedHours >= 11.0 && !isOver;
              final barColor = isOver ? AppTheme.errorColor : (isWarning ? const Color(0xFFF59E0B) : AppTheme.secondaryColor);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(emp.employeeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryColor), overflow: TextOverflow.ellipsis)),
                        Text('${emp.weeklyAccumulatedHours} / 14.0 Jam', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: barColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: barColor,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _handleApproval(OvertimeRequestItem item, String status) {
    ref.read(overtimeControllerProvider.notifier).updateStatus(item.id, status);
    AppToast.show(
      context,
      title: status == 'Disetujui' ? 'Lembur Disetujui' : 'Lembur Ditolak',
      message: 'Pengajuan lembur atas nama ${item.employeeName} senilai ${item.formattedCompensation} telah $status.',
      type: status == 'Disetujui' ? ToastType.success : ToastType.error,
    );
  }

  void _showAddOvertimeModal() {
    final nameCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '3.0');
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.post_add_rounded, color: AppTheme.tealButton, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Catat Lembur Manual (HR)', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.primaryColor), overflow: TextOverflow.ellipsis),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Menambahkan catatan jam kerja ekstra langsung ke database payroll.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Karyawan', hintText: 'Contoh: Dionisius Pratama')),
            const SizedBox(height: 12),
            TextField(controller: nikCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'NIK / ID', hintText: 'Contoh: 2026001')),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Durasi Lembur (Jam)', suffixText: 'Jam')),
            const SizedBox(height: 12),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Alasan / Pekerjaan Tambahan', hintText: 'Contoh: Lembur maintenance server production')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealButton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                label: const Text('Simpan Data Lembur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && durationCtrl.text.isNotEmpty) {
                    final intHours = int.tryParse(durationCtrl.text.split('.').first) ?? 2;
                    final newReq = OvertimeRequestItem(
                      id: 'OV-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                      employeeName: nameCtrl.text.trim(),
                      nik: nikCtrl.text.trim().isEmpty ? '2026031' : nikCtrl.text.trim(),
                      department: 'IT & Operations',
                      date: 'Hari Ini, 5 Agt 2026',
                      startTime: '17:00',
                      endTime: '${17 + intHours}:00',
                      durationHours: double.tryParse(durationCtrl.text.trim()) ?? 2.0,
                      reason: reasonCtrl.text.isNotEmpty ? reasonCtrl.text.trim() : 'Pekerjaan tambahan di luar jam kerja reguler.',
                      avatarBg: AppTheme.tealButton,
                      status: 'Disetujui',
                    );
                    ref.read(overtimeControllerProvider.notifier).addRequest(newReq);
                    Navigator.pop(ctx);
                    AppToast.show(
                      context,
                      title: 'Lembur Dicatat',
                      message: 'Data lembur ${nameCtrl.text} berhasil disetujui & dimasukkan ke kalkulasi payroll.',
                      type: ToastType.success,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
