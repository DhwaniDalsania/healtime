import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/doctor.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/widgets/custom_bottom_nav.dart';
import 'package:healtime_app/widgets/doctor_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:healtime_app/models/auth_provider.dart';

import 'package:healtime_app/utils/api_service.dart';

class DoctorDiscoveryScreen extends StatefulWidget {
  const DoctorDiscoveryScreen({super.key});

  @override
  State<DoctorDiscoveryScreen> createState() => _DoctorDiscoveryScreenState();
}

class _DoctorDiscoveryScreenState extends State<DoctorDiscoveryScreen> {
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final List<dynamic> docs = await ApiService.get('/doctors');
      setState(() {
        _doctors = docs.map((d) => Doctor.fromMap(d)).toList();
        _filteredDoctors = List.from(_doctors);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch =
            doctor.name.toLowerCase().contains(query) ||
            doctor.specialty.toLowerCase().contains(query);
        final matchesCategory =
            _selectedCategory == 'All' ||
            doctor.specialty.toLowerCase().contains(
              _selectedCategory.toLowerCase(),
            );
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME TO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'Heal Time',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                context.read<AuthProvider>().logout(),
                            icon: const Icon(Symbols.logout, size: 20),
                            tooltip: 'Logout',
                          ),
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Symbols.notifications,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.search,
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search doctor or specialty...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Categories
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _filterDoctors();
                              });
                            },
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildCategoryItem(Symbols.grid_view, 'All'),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            Symbols.medical_services,
                            'General',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(Symbols.cardiology, 'Heart'),
                          const SizedBox(width: 16),
                          _buildCategoryItem(Symbols.face, 'Dermato'),
                          const SizedBox(width: 16),
                          _buildCategoryItem(Symbols.child_care, 'Pediatric'),
                        ],
                      ),
                    ),

                    // Recommended Doctors
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Symbols.tune,
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _filteredDoctors.isEmpty
                          ? const Text("No doctors found")
                          : Column(
                              children: _filteredDoctors
                                  .map(
                                    (doctor) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: DoctorCard(
                                        doctor: doctor,
                                        onBook: () => context.push(
                                          '/booking',
                                          extra: doctor,
                                        ),
                                        onChat: () => context.push(
                                          '/chat-room',
                                          extra: doctor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 100), // Bottom space for nav
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _filterDoctors();
        });
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? null
                  : Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
