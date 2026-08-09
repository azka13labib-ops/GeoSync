import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../admin/presentation/controllers/admin_leave_controller.dart';
import '../../../admin/presentation/controllers/overtime_controller.dart';
import '../../../overtime/models/overtime_request.dart';

class EmployeeRequestsTab extends ConsumerStatefulWidget {
  const EmployeeRequestsTab({super.key});

  @override
  ConsumerState<EmployeeRequestsTab> createState() => _EmployeeRequestsTabState();
}

class _EmployeeRequestsTabState extends ConsumerState<EmployeeRequestsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengajuan Mandiri', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Cuti'),
            Tab(text: 'Lembur'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const DotPatternPainter(
                dotColor: Color(0xFFCBD5E1),
                spacing: 24,
                radius: 1.5,
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: const [
              _LeaveForm(),
              _OvertimeForm(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaveForm extends ConsumerStatefulWidget {
  const _LeaveForm();
  @override
  ConsumerState<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends ConsumerState<_LeaveForm> {
  final _reasonController = TextEditingController();
  String _leaveType = 'Cuti Tahunan';
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submit() {
    if (_startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      AppToast.show(context, title: 'Error', message: 'Harap lengkapi tanggal dan alasan cuti.', type: ToastType.error);
      return;
    }

    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final format = DateFormat('d MMM yyyy', 'id_ID');
    
    final item = LeaveRequestItem(
      id: 'LV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      employeeName: user.fullName,
      department: 'Umum',
      leaveType: _leaveType,
      startDate: format.format(_startDate!),
      endDate: format.format(_endDate!),
      reason: _reasonController.text,
      avatarBg: AppTheme.primaryColor,
      status: 'Pending',
    );

    ref.read(adminLeaveControllerProvider.notifier).addLeaveRequest(item);
    
    AppToast.show(context, title: 'Berhasil', message: 'Pengajuan cuti berhasil dikirim.', type: ToastType.success);
    
    setState(() {
      _reasonController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jenis Cuti', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _leaveType,
                  decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF8FAFD)),
                  items: ['Cuti Tahunan', 'Izin Sakit', 'Cuti Melahirkan', 'Cuti Penting']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _leaveType = val!),
                ),
                const SizedBox(height: 20),
                const Text('Tanggal Cuti', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('d MMM yyyy').format(_startDate!)} - ${DateFormat('d MMM yyyy').format(_endDate!)}'
                              : 'Pilih rentang tanggal',
                          style: TextStyle(color: _startDate != null ? AppTheme.textPrimary : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Alasan Cuti', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan alasan pengajuan cuti Anda...',
                    filled: true,
                    fillColor: Color(0xFFF8FAFD),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Kirim Pengajuan Cuti'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OvertimeForm extends ConsumerStatefulWidget {
  const _OvertimeForm();
  @override
  ConsumerState<_OvertimeForm> createState() => _OvertimeFormState();
}

class _OvertimeFormState extends ConsumerState<_OvertimeForm> {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _compensationType = 'Uang Lembur (Rate UU)';

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 17, minute: 0) : const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  void _submit() {
    if (_selectedDate == null || _startTime == null || _endTime == null || _reasonController.text.isEmpty) {
      AppToast.show(context, title: 'Error', message: 'Harap lengkapi semua field lembur.', type: ToastType.error);
      return;
    }

    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final format = DateFormat('d MMMM yyyy', 'id_ID');
    final sTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    final eTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    // Calculate duration roughly
    final startMins = _startTime!.hour * 60 + _startTime!.minute;
    final endMins = _endTime!.hour * 60 + _endTime!.minute;
    var dur = (endMins - startMins) / 60.0;
    if (dur < 0) dur += 24; // If crossed midnight

    final item = OvertimeRequestItem(
      id: 'OV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      employeeName: user.fullName,
      nik: user.nik,
      department: 'Umum',
      date: format.format(_selectedDate!),
      startTime: sTime,
      endTime: eTime,
      durationHours: dur,
      reason: _reasonController.text,
      avatarBg: AppTheme.secondaryColor,
      status: 'Pending',
      compensationType: _compensationType,
    );

    ref.read(overtimeControllerProvider.notifier).addRequest(item);
    
    AppToast.show(context, title: 'Berhasil', message: 'Pengajuan lembur berhasil dikirim.', type: ToastType.success);
    
    setState(() {
      _reasonController.clear();
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tanggal Lembur', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null ? DateFormat('d MMM yyyy').format(_selectedDate!) : 'Pilih tanggal',
                          style: TextStyle(color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Mulai', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFD),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                _startTime != null ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}' : '--:--',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Selesai', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFD),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                _endTime != null ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}' : '--:--',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const Text('Kompensasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _compensationType,
                  decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF8FAFD)),
                  items: ['Uang Lembur (Rate UU)', 'Cuti Pengganti (Comp Leave)']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _compensationType = val!),
                ),
                const SizedBox(height: 20),
                
                const Text('Alasan & Deskripsi Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan deskripsi pekerjaan lembur...',
                    filled: true,
                    fillColor: Color(0xFFF8FAFD),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Kirim Pengajuan Lembur'),
            ),
          ),
        ],
      ),
    );
  }
}
