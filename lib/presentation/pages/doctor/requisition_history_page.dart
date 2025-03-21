import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/data/repositories/lab_repository_impl.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequisitionHistoryPage extends StatefulWidget {
  const RequisitionHistoryPage({super.key});

  @override
  State<RequisitionHistoryPage> createState() => _RequisitionHistoryPageState();
}

class _RequisitionHistoryPageState extends State<RequisitionHistoryPage> {
  late List<Requisition> _requisitions = [];
  bool _isLoading = true;
  late LabRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    try {
      _repository = sl<LabRepositoryImpl>();
    } catch (e) {
      try {
        _repository = sl<LabRepository>() as LabRepositoryImpl;
      } catch (e) {
        final sharedPreferences = sl<SharedPreferences>();
        _repository = LabRepositoryImpl(sharedPreferences: sharedPreferences);
      }
    }
    _loadRequisitions();
  }

  Future<void> _loadRequisitions() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final requisitions = _repository.getRequisitions();

    requisitions.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    setState(() {
      _requisitions = requisitions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requisition History'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequisitions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requisitions.isEmpty
              ? _buildEmptyState()
              : _buildRequisitionList(),
    );
  }

  Widget _buildEmptyState() {
    return ResponsiveContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No requisitions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Submit a lab requisition to see it here',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/doctor'),
              child: const Text('Create New Requisition'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequisitionList() {
    return ResponsiveContainer(
      child: ListView.builder(
        itemCount: _requisitions.length,
        itemBuilder: (context, index) {
          final requisition = _requisitions[index];
          final hasResults = _repository.hasLabReport(requisition.id);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                requisition.patient.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Test: ${requisition.laboratoryTest}'),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${requisition.orderDate.toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          requisition.id,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: requisition.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Requisition ID copied to clipboard',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copy ID',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(hasResults ? 'Results Available' : 'Pending'),
                    backgroundColor:
                        hasResults
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                    avatar: Icon(
                      hasResults ? Icons.check_circle : Icons.hourglass_empty,
                      size: 16,
                      color: hasResults ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      context.go('/doctor/report/${requisition.id}');
                    },
                    tooltip: 'View Report',
                  ),
                  IconButton(
                    icon: const Icon(Icons.science),
                    onPressed: () {
                      context.go('/lab/${requisition.id}');
                    },
                    tooltip: 'Go to Lab',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
