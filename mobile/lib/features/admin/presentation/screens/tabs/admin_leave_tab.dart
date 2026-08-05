// ====================================================================
// GEOSYNC - ADMIN LEAVE APPROVAL TAB (PORTAL HRD TAB 3)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../controllers/admin_leave_controller.dart';
import '../../widgets/admin_app_bar.dart';

class AdminLeaveTab extends ConsumerStatefulWidget {
  const AdminLeaveTab({super.key});

  @override
  ConsumerState<AdminLeaveTab> createState() => _AdminLeaveTabState();
}

class _AdminLeaveTabState extends ConsumerState<AdminLeaveTab> {
  String _activeTab = 'Pending';

  void _updateStatus(LeaveRequestItem item, String newStatus) {
    ref.read(adminLeaveControllerProvider.notifier).updateStatus(item.id, newStatus);
    AppToast.show(
      context,
      title: newStatus == 'Disetujui' ? 'Cuti Disetujui' : 'Cuti Ditolak',
      message: 'Status pengajuan cuti ${item.employeeName} telah diubah menjadi $newStatus.',
      type: newStatus == 'Disetujui' ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(adminLeaveControllerProvider);
    final displayedList = requests.where((req) => req.status == _activeTab).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared Header
                  const AdminAppBar(notificationCount: 3),
                  const SizedBox(height: 20),
                  const Text('Persetujuan Cuti', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  const SizedBox(height: 16),

                  // Segmented Control Tabs Box
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildSegmentTab('Pending')),
                        Expanded(child: _buildSegmentTab('Disetujui')),
                        Expanded(child: _buildSegmentTab('Ditolak')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Request Cards List
            Expanded(
              child: displayedList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('Tidak ada pengajuan pada tab "$_activeTab".', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: displayedList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final req = displayedList[index];
                        final isTahunan = req.leaveType == 'Tahunan';

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.borderLight, width: 1.2),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Avatar + Name + Leave Type Badge
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: req.avatarBg,
                                    child: Text(req.employeeName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req.employeeName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text(req.department, style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isTahunan ? AppTheme.badgeMintBg : AppTheme.badgeRedBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      req.leaveType,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isTahunan ? AppTheme.badgeMintText : AppTheme.badgeRedText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Inner Date & Reason Box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFD),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Tanggal Mulai', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Text(req.startDate, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Tanggal Selesai', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Text(req.endDate, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    const Text('Alasan', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(req.reason, style: const TextStyle(fontSize: 14.5, color: AppTheme.textPrimary, height: 1.4)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Action Buttons (Approve / Reject) or Status Indicator
                              if (req.status == 'Pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateStatus(req, 'Disetujui'),
                                        icon: const Icon(Icons.check_circle_outline, size: 20),
                                        label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.tealButton,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _updateStatus(req, 'Ditolak'),
                                        icon: const Icon(Icons.cancel_outlined, size: 20, color: AppTheme.errorColor),
                                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.errorColor)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          side: const BorderSide(color: AppTheme.errorColor, width: 1.4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Center(
                                  child: Text(
                                    'Status Pengajuan: ${req.status}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: req.status == 'Disetujui' ? AppTheme.secondaryColor : AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(String title) {
    final isSelected = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
