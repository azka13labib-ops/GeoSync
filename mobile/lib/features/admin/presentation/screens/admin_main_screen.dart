// ====================================================================
// GEOSYNC - ADMIN MAIN PORTAL CONTAINER (SLIDING MINT NAVBAR PILL)
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;
              const pillHeight = 54.0;

              return SizedBox(
                height: pillHeight,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // LAYER 1: KOTAK HIJAU MINT YANG BERGESER MELUNCUR (SLIDING PILL)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      left: _selectedIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.mintNavPill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // LAYER 2: DERETAN IKON & TEKS MENU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildNavItem(0, Icons.grid_view_rounded, 'Dasbor'),
                        _buildNavItem(1, Icons.people_alt_rounded, 'Data Karyawan'),
                        _buildNavItem(2, Icons.assignment_turned_in_rounded, 'Cuti'),
                        _buildNavItem(3, Icons.download_rounded, 'Export'),
                        _buildNavItem(4, Icons.settings_rounded, 'Settings'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.tealButton : const Color(0xFF4A5568),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.tealButton,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
