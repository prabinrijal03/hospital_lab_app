import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';
import 'package:hospital_lab_app/data/repositories/lab_repository_impl.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  late LabRepositoryImpl _repository;
  int _totalRequisitions = 0;
  int _completedReports = 0;
  int _pendingReports = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    setState(() {
      _isLoading = true;
    });

    final sharedPreferences = await SharedPreferences.getInstance();

    _repository = LabRepositoryImpl(sharedPreferences: sharedPreferences);

    _loadStats();
  }

  void _loadStats() {
    final requisitions = _repository.getRequisitions();
    int completed = 0;
    int pending = 0;

    for (var req in requisitions) {
      if (_repository.hasLabReport(req.id)) {
        completed++;
      } else {
        pending++;
      }
    }

    setState(() {
      _totalRequisitions = requisitions.length;
      _completedReports = completed;
      _pendingReports = pending;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Lab App'), centerTitle: true),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.spacingLarge),
              _buildHeader(),
              SizedBox(height: context.spacingXLarge),
              _buildStatistics(),
              SizedBox(height: context.spacingXLarge),
              _buildRoleSelection(),
              SizedBox(height: context.spacingXLarge),
              _buildWorkflowSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.spacingLarge),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: context.borderRadiusXLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.white, size: 40),
              SizedBox(width: context.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Laboratory',
                      style: context.headingLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Manage lab requisitions and reports',
                      style: context.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: context.spacingMedium,
                bottom: context.spacingSmall,
              ),
              child: Text('Dashboard', style: context.headingMedium),
            ),
            Row(
              children: [
                _buildStatCard(
                  'Total Requisitions',
                  _totalRequisitions.toString(),
                  Icons.description,
                  context.infoColor,
                ),
                _buildStatCard(
                  'Completed Reports',
                  _completedReports.toString(),
                  Icons.check_circle,
                  context.successColor,
                ),
                _buildStatCard(
                  'Pending Reports',
                  _pendingReports.toString(),
                  Icons.hourglass_empty,
                  context.warningColor,
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.all(context.spacingSmall),
        child: Padding(
          padding: EdgeInsets.all(context.spacingMedium),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: context.spacingSmall),
              Text(value, style: context.headingLarge.copyWith(color: color)),
              SizedBox(height: context.spacingXSmall),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.bodySmall.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: context.spacingMedium,
            bottom: context.spacingMedium,
          ),
          child: Text('Select your role', style: context.headingMedium),
        ),
        MediaQuery.of(context).size.width < 600
            ? Column(
              children: [
                _buildRoleCard(
                  'Doctor',
                  'Create requisitions and view lab reports',
                  Icons.medical_services,
                  context.infoColor,
                  () => context.go('/doctor'),
                ),
                _buildRoleCard(
                  'Lab Technician',
                  'Process requisitions and submit test results',
                  Icons.science,
                  context.successColor,
                  () => context.go('/lab'),
                ),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    'Doctor',
                    'Create requisitions and view lab reports',
                    Icons.medical_services,
                    context.infoColor,
                    () => context.go('/doctor'),
                  ),
                ),
                Expanded(
                  child: _buildRoleCard(
                    'Lab Technician',
                    'Process requisitions and submit test results',
                    Icons.science,
                    context.successColor,
                    () => context.go('/lab'),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _buildRoleCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.all(context.spacingSmall),
      child: InkWell(
        onTap: () {
          if (title == 'Doctor') {
            _showDoctorOptionsDialog(context);
          } else {
            onTap();
          }
        },
        borderRadius: context.borderRadiusLarge,
        child: Padding(
          padding: EdgeInsets.all(context.spacingLarge),
          child: Column(
            children: [
              Icon(icon, color: color, size: 48),
              SizedBox(height: context.spacingMedium),
              Text(title, style: context.headingMedium),
              SizedBox(height: context.spacingSmall),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: context.spacingMedium),
              ElevatedButton(
                onPressed: () {
                  if (title == 'Doctor') {
                    _showDoctorOptionsDialog(context);
                  } else {
                    onTap();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: Text('Continue as $title'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowSection() {
    return Container(
      padding: EdgeInsets.all(context.spacingMedium),
      decoration: BoxDecoration(
        color: context.infoBackgroundColor,
        borderRadius: context.borderRadiusLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Complete Workflow', style: context.headingSmall),
          SizedBox(height: context.spacingMedium),
          _buildWorkflowStep(
            '1',
            'Doctor creates lab requisition',
            Icons.medical_services,
          ),
          SizedBox(height: context.spacingSmall),
          _buildWorkflowStep(
            '2',
            'Lab technician enters test results',
            Icons.science,
          ),
          SizedBox(height: context.spacingSmall),
          _buildWorkflowStep(
            '3',
            'Doctor views completed lab report',
            Icons.description,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: context.spacingSmall),
        Icon(icon, size: 20, color: context.primaryColor),
        SizedBox(width: context.spacingSmall),
        Expanded(child: Text(text, style: context.bodyMedium)),
      ],
    );
  }

  void _showDoctorOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Doctor Option', style: context.headingMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDoctorOptionCard(
                  context,
                  'Doctor Homepage',
                  'Create new lab requisitions',
                  Icons.medical_services,
                  context.primaryColor,
                  () => context.go('/doctor'),
                ),
                SizedBox(height: context.spacingMedium),
                _buildDoctorOptionCard(
                  context,
                  'Reports History',
                  'View your previous reports',
                  Icons.history,
                  context.infoColor,
                  () => context.go('/doctor/history'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildDoctorOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: context.borderRadiusMedium,
        child: Padding(
          padding: EdgeInsets.all(context.spacingMedium),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.spacingMedium),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: context.borderRadiusMedium,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(width: context.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.headingSmall),
                    SizedBox(height: context.spacingXSmall),
                    Text(
                      description,
                      style: context.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
