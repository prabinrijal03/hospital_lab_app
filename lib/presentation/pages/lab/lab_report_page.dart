import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/data/models/lab_report_model.dart';
import 'package:hospital_lab_app/data/models/test_result_model.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/presentation/bloc/lab_report/lab_report_bloc.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:hospital_lab_app/presentation/widgets/app_drawer.dart';

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
  final _resultController = TextEditingController();
  final _referenceRangeController = TextEditingController(text: '4000 – 11000/microliter');
  LabReport? _labReport;
  bool _isReportSubmitted = false;
  late LabReportBloc _labReportBloc;
  
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
    _resultController.dispose();
    _referenceRangeController.dispose();
    super.dispose();
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
        drawer: const AppDrawer(currentRoute: '/lab'),
        body: BlocConsumer<LabReportBloc, LabReportState>(
          listener: (context, state) {
            if (state is LabReportLoaded) {
              setState(() {
                _labReport = state.labReport;
                _isReportSubmitted = false;
                
                // Check if this report already has results
                if (state.labReport.testResults.isNotEmpty && 
                    state.labReport.testResults.first.result != 'Pending') {
                  _resultController.text = state.labReport.testResults.first.result;
                  _referenceRangeController.text = state.labReport.testResults.first.referenceRange;
                  _isReportSubmitted = true;
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
                                  DateTime.now().toString().split(' ')[0],
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
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Test: ${_getTestName()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _resultController,
                                  decoration: const InputDecoration(
                                    labelText: 'Test Result',
                                    hintText: 'e.g. 16000/microliter',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter test result';
                                    }
                                    return null;
                                  },
                                  enabled: !_isReportSubmitted,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _referenceRangeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Reference Range',
                                    border: OutlineInputBorder(),
                                    helperText: 'Normal range for this test',
                                  ),
                                  enabled: !_isReportSubmitted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isReportSubmitted ? null : () {
                              if (_formKey.currentState!.validate()) {
                                // Create updated lab report with test results
                                final updatedLabReport = LabReportModel(
                                  id: _labReport!.id,
                                  patient: _labReport!.patient,
                                  labResultDate: DateTime.now(),
                                  laboratoryTest: _labReport!.laboratoryTest,
                                  testResults: [
                                    TestResultModel(
                                      testName: _getTestName(),
                                      result: _resultController.text,
                                      referenceRange: _referenceRangeController.text,
                                    ),
                                  ],
                                );
                                
                                _labReportBloc.add(
                                  SubmitLabReportEvent(labReport: updatedLabReport),
                                );
                              }
                            },
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
  
  String _getTestName() {
    if (_labReport!.testResults.isNotEmpty) {
      return _labReport!.testResults.first.testName;
    } else if (_labReport!.laboratoryTest != null) {
      return _labReport!.laboratoryTest!;
    } else {
      return "Total leucocyte count";
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

