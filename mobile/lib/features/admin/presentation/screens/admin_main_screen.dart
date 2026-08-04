// ====================================================================
// GEOSYNC - ADMIN MAIN PORTAL CONTAINER (CUSTOM BOTTOM NAV WITH MINT PILL)
// ====================================================================

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_employees_tab.dart';
import 'tabs/admin_leave_tab.dart';
import 'tabs/admin_export_tab.dart';
import 'tabs/admin_settings_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminDashboardTab(onNavigateToLeave: () => _switchTab(2)),
      const AdminEmployeesTab(),
      const AdminLeaveTab(),
      const AdminExportTab(),
      const AdminSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavPill(
                index: 0,
                icon: Icons.grid_view_rounded,
                label: 'Dasbor',
              ),
              _buildNavPill(
                index: 1,
                icon: Icons.people_alt_rounded,
                label: 'Data Karyawan',
              ),
              _buildNavPill(
                index: 2,
                icon: Icons.assignment_turned_in_rounded,
                label: 'Cuti',
              ),
              _buildNavPill(
                index: 3,
                icon: Icons.download_rounded,
                label: 'Export',
              ),
              _buildNavPill(
                index: 4,
                icon: Icons.settings_rounded,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavPill({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mintNavPill : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.tealButton : const Color(0xFF4A5568),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tealButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
