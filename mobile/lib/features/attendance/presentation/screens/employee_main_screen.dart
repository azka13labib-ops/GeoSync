import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'employee_home_screen.dart';
import 'employee_camera_screen.dart';
import 'employee_requests_tab.dart';

class EmployeeMainScreen extends ConsumerStatefulWidget {
  const EmployeeMainScreen({super.key});

  @override
  ConsumerState<EmployeeMainScreen> createState() => _EmployeeMainScreenState();
}

class _EmployeeMainScreenState extends ConsumerState<EmployeeMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EmployeeHomeScreen(),
    const EmployeeCameraScreen(),
    const EmployeeRequestsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
              final itemWidth = constraints.maxWidth / 3;
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
                      left: _currentIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                        _buildNavItem(0, Icons.dashboard_rounded, 'Beranda'),
                        _buildNavItem(1, Icons.camera_alt_rounded, 'Absen'),
                        _buildNavItem(2, Icons.description_rounded, 'Pengajuan'),
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
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
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
