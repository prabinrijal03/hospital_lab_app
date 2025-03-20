import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/data/models/lab_report_model.dart';
import 'package:hospital_lab_app/data/models/test_result_model.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/entities/test_result.dart';
import 'package:hospital_lab_app/presentation/bloc/lab_report/lab_report_bloc.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:intl/intl.dart';

class LabReportPage extends StatefulWidget {
  final String? initialRequisitionId;
  
  const LabReportPage({
    super.key,
    this.initialRequisitionId,
  });

  @override
  State<LabReportPage> createState() => _LabReportPageState();
}

class _LabReportPageState extends State<LabReportPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _requisitionIdController;
  LabReport? _labReport;
  bool _isReportSubmitted = false;
  late LabReportBloc _labReportBloc;
  
  // List to store test result controllers
  final List<TestResultEntry> _testResults = [];
  
  @override
  void initState() {
    super.initState();
    _requisitionIdController = TextEditingController(text: widget.initialRequisitionId ?? '');
    _labReportBloc = sl<LabReportBloc>();
    
    // If we have an initial requisition ID, fetch the report
    if (widget.initialRequisitionId != null && widget.initialRequisitionId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchLabReport();
      });
    }
  }
  
  void _fetchLabReport() {
    if (_requisitionIdController.text.isNotEmpty) {
      _labReportBloc.add(
        GetLabReportEvent(id: _requisitionIdController.text),
      );
    }
  }
  
  @override
  void dispose() {
    _requisitionIdController.dispose();
    for (var entry in _testResults) {
      entry.dispose();
    }
    super.dispose();
  }
  
  void _addTestResult({TestResult? existingTest}) {
    setState(() {
      _testResults.add(
        TestResultEntry(
          testNameController: TextEditingController(text: existingTest?.testName ?? ''),
          resultController: TextEditingController(text: existingTest?.result != 'Pending' ? existingTest?.result : ''),
          referenceRangeController: TextEditingController(text: existingTest?.referenceRange ?? ''),
          unitController: TextEditingController(text: existingTest?.unit ?? ''),
          isReadOnly: existingTest != null && existingTest.result != 'Pending',
        ),
      );
    });
  }
  
  void _removeTestResult(int index) {
    setState(() {
      _testResults[index].dispose();
      _testResults.removeAt(index);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _labReportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Report Form'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/doctor'),
              tooltip: 'Switch to Doctor View',
            ),
          ],
        ),
        body: BlocConsumer<LabReportBloc, LabReportState>(
          listener: (context, state) {
            if (state is LabReportLoaded) {
              setState(() {
                _labReport = state.labReport;
                _isReportSubmitted = false;
                
                // Clear existing test results
                for (var entry in _testResults) {
                  entry.dispose();
                }
                _testResults.clear();
                
                // Check if this report already has results
                if (state.labReport.testResults.isNotEmpty) {
                  // Add each test result to the form
                  for (var test in state.labReport.testResults) {
                    _addTestResult(existingTest: test);
                  }
                  
                  // Check if any test has a non-pending result
                  _isReportSubmitted = state.labReport.testResults.any(
                    (test) => test.result != 'Pending'
                  );
                } else {
                  // Add an empty test result form
                  _addTestResult();
                }
              });
            } else if (state is LabReportSubmitSuccess) {
              setState(() {
                _isReportSubmitted = true;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lab report submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Refresh the lab report to see the updated data
              _labReportBloc.add(
                GetLabReportEvent(id: _requisitionIdController.text),
              );
              
              // Show dialog with option to view as doctor
              _showSubmitSuccessDialog(context);
            } else if (state is LabReportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LabReportSubmitting || state is LabReportLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return ResponsiveContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Requisition ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask the doctor for the requisition ID that was generated when they submitted the lab requisition form.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _requisitionIdController,
                              decoration: const InputDecoration(
                                labelText: 'Requisition ID',
                                hintText: 'Enter the ID provided by the doctor',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter requisition ID';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _fetchLabReport,
                            child: const Text('Fetch'),
                          ),
                        ],
                      ),
                      if (_labReport != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Patient Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Name', _labReport!.patient.name),
                                _buildInfoRow('Age', '${_labReport!.patient.age} years'),
                                _buildInfoRow('Address', _labReport!.patient.address),
                                _buildInfoRow(
                                  'Lab Result Date',
                                  DateFormat('yyyy-MM-dd').format(_labReport!.labResultDate),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Test Results',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isReportSubmitted)
                              Chip(
                                label: const Text('Results Submitted'),
                                backgroundColor: Colors.green.shade100,
                                avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._buildTestResultForms(),
                        if (!_isReportSubmitted) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => _addTestResult(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Another Test'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isReportSubmitted ? null : _submitLabReport,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _isReportSubmitted ? 'Results Already Submitted' : 'Submit Lab Report',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        if (_isReportSubmitted) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.go('/doctor/report/${_labReport!.id}');
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text('View as Doctor'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  List<Widget> _buildTestResultForms() {
    return List.generate(_testResults.length, (index) {
      final entry = _testResults[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Test ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!_isReportSubmitted && _testResults.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTestResult(index),
                      tooltip: 'Remove Test',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: entry.testNameController,
                decoration: const InputDecoration(
                  labelText: 'Test Name',
                  hintText: 'e.g. Total leucocyte count',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter test name';
                  }
                  return null;
                },
                enabled: !entry.isReadOnly,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: entry.resultController,
                      decoration: const InputDecoration(
                        labelText: 'Test Result',
                        hintText: 'e.g. 16000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter test result';
                        }
                        return null;
                      },
                      enabled: !entry.isReadOnly,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: entry.unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g. /microliter',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !entry.isReadOnly,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: entry.referenceRangeController,
                decoration: const InputDecoration(
                  labelText: 'Reference Range',
                  hintText: 'e.g. 4000 – 11000',
                  border: OutlineInputBorder(),
                  helperText: 'Normal range for this test',
                ),
                enabled: !entry.isReadOnly,
              ),
            ],
          ),
        ),
      );
    });
  }
  
  void _submitLabReport() {
    if (_formKey.currentState!.validate() && _testResults.isNotEmpty) {
      // Create test results list
      final testResults = _testResults.map((entry) {
        return TestResultModel(
          testName: entry.testNameController.text,
          result: entry.resultController.text,
          referenceRange: entry.referenceRangeController.text,
          unit: entry.unitController.text.isNotEmpty ? entry.unitController.text : null,
        );
      }).toList();
      
      // Create updated lab report with test results
      final updatedLabReport = LabReportModel(
        id: _labReport!.id,
        patient: _labReport!.patient,
        labResultDate: DateTime.now(),
        laboratoryTest: _labReport!.laboratoryTest,
        testResults: testResults,
      );
      
      _labReportBloc.add(
        SubmitLabReportEvent(labReport: updatedLabReport),
      );
    }
  }
  
  void _showSubmitSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted Successfully'),
        content: const Text(
          'The lab report has been submitted successfully. Would you like to view the report as a doctor to see how it appears?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Stay Here'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/doctor/report/${_labReport!.id}');
            },
            child: const Text('View as Doctor'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class TestResultEntry {
  final TextEditingController testNameController;
  final TextEditingController resultController;
  final TextEditingController referenceRangeController;
  final TextEditingController unitController;
  final bool isReadOnly;
  
  TestResultEntry({
    required this.testNameController,
    required this.resultController,
    required this.referenceRangeController,
    required this.unitController,
    this.isReadOnly = false,
  });
  
  void dispose() {
    testNameController.dispose();
    resultController.dispose();
    referenceRangeController.dispose();
    unitController.dispose();
  }
}

