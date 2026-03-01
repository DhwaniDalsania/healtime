import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/models/record.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/widgets/custom_bottom_nav.dart';
import 'package:file_picker/file_picker.dart';

class PatientRecordsScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;

  const PatientRecordsScreen({super.key, this.patientId, this.patientName});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  bool _isLoading = true;
  List<PatientRecord> _records = [];
  String _searchQuery = '';
  String _selectedFilter = 'All Records';

  final List<String> _filters = [
    'All Records',
    'Lab Reports',
    'Prescriptions',
    'Imaging',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final auth = context.read<AuthProvider>();
      final uId = widget.patientId ?? auth.userId;
      if (uId == null) return;
      final List<dynamic> data = await ApiService.getRecords(uId);
      setState(() {
        _records = data.map((r) => PatientRecord.fromMap(r)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching records: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showRecordDetails(PatientRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor: Dr. ${record.doctorName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${record.date}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            const Text(
              'Diagnosis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(record.diagnosis),
            const SizedBox(height: 16),
            const Text(
              'Prescription:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              record.prescription.isEmpty
                  ? 'No prescription provided.'
                  : record.prescription,
            ),
            if (record.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Attachments:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                    'http://10.69.53.163:5000${record.attachments.first}',
                  );
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open document'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Symbols.visibility),
                label: const Text('View Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForFilter(String diagnosis) {
    if (diagnosis.toLowerCase().contains('blood') ||
        diagnosis.toLowerCase().contains('lab')) {
      return Symbols.description;
    } else if (diagnosis.toLowerCase().contains('x-ray') ||
        diagnosis.toLowerCase().contains('imaging') ||
        diagnosis.toLowerCase().contains('scan')) {
      return Symbols.radiology;
    } else if (diagnosis.toLowerCase().contains('ecg') ||
        diagnosis.toLowerCase().contains('heart')) {
      return Symbols.ecg;
    }
    return Symbols.prescriptions;
  }

  Color _getColorForFilter(String diagnosis) {
    final icon = _getIconForFilter(diagnosis);
    if (icon == Symbols.description) return AppTheme.secondary;
    if (icon == Symbols.radiology) return const Color(0xFFAABAAE);
    if (icon == Symbols.ecg) return AppTheme.primary;
    return AppTheme.accent;
  }

  void _showAddRecordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddRecordForm(targetPatientId: widget.patientId),
    ).then((_) {
      _fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredRecords = _records.where((record) {
      final matchesSearch =
          record.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.doctorName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All Records') return true;
      if (_selectedFilter == 'Lab Reports') {
        return record.diagnosis.toLowerCase().contains('blood') ||
            record.diagnosis.toLowerCase().contains('lab');
      }
      if (_selectedFilter == 'Imaging') {
        return record.diagnosis.toLowerCase().contains('x-ray') ||
            record.diagnosis.toLowerCase().contains('scan');
      }
      return true; // Simple fallback for Prescriptions or others
    }).toList();

    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordSheet,
        backgroundColor: AppTheme.primary,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/patient-dashboard');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_back,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    widget.patientName != null
                        ? '${widget.patientName}\'s Records'
                        : 'Heal Time',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.notifications,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Records',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Symbols.search, color: AppTheme.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search documents, doctors...',
                              hintStyle: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                              ),
                        boxShadow: isSelected && !isDark
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primary,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          if (!isSelected) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Symbols.expand_more,
                              color: AppTheme.primary,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Recent Documents List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _records.isEmpty
                          ? const Center(
                              child: Text('No medical records found'),
                            )
                          : ListView.separated(
                              itemCount: filteredRecords.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                final color = _getColorForFilter(
                                  record.diagnosis,
                                );
                                final icon = _getIconForFilter(
                                  record.diagnosis,
                                );

                                return GestureDetector(
                                  onTap: () => _showRecordDetails(record),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.transparent,
                                      ),
                                      boxShadow: [
                                        if (!isDark)
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                            blurRadius: 10,
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            icon,
                                            color: color,
                                            size: 32,
                                            fill: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.diagnosis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Dr. ${record.doctorName}',
                                                style: const TextStyle(
                                                  color: AppTheme.accent,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                record.date,
                                                style: const TextStyle(
                                                  color: AppTheme.secondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Symbols.more_vert,
                                          color: AppTheme.accent,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddRecordForm extends StatefulWidget {
  final String? targetPatientId;

  const AddRecordForm({super.key, this.targetPatientId});

  @override
  State<AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    if (auth.userId == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final pId = widget.targetPatientId ?? auth.userId!;

    final result = await ApiService.addRecordWithFile(
      patientId: pId,
      doctorId: auth.userId!,
      doctorName: _doctorController.text,
      date: dateStr,
      diagnosis: _diagnosisController.text,
      prescription: _prescriptionController.text,
      fileBytes: _selectedFileBytes,
      fileName: _selectedFileName,
    );

    setState(() => _isSubmitting = false);

    if (result != null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add record')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Record',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorController,
              decoration: const InputDecoration(labelText: 'Doctor Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(labelText: 'Diagnosis'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prescriptionController,
              decoration: const InputDecoration(
                labelText: 'Prescription (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: const Text(
                    'Change',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFileName != null
                        ? 'Selected: $_selectedFileName'
                        : 'No PDF selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(
                    Symbols.upload_file,
                    color: AppTheme.primary,
                  ),
                  label: const Text(
                    'Upload PDF',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Record',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
