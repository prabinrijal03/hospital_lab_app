import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/entities/test_result.dart';
import 'package:hospital_lab_app/presentation/bloc/lab_report/lab_report_bloc.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:intl/intl.dart';

class LabReportViewPage extends StatefulWidget {
  final String requisitionId;

  const LabReportViewPage({super.key, required this.requisitionId});

  @override
  State<LabReportViewPage> createState() => _LabReportViewPageState();
}

class _LabReportViewPageState extends State<LabReportViewPage> {
  late LabReportBloc _labReportBloc;

  @override
  void initState() {
    super.initState();
    _labReportBloc = sl<LabReportBloc>();
    _fetchLabReport();
  }

  void _fetchLabReport() {
    _labReportBloc.add(GetLabReportEvent(id: widget.requisitionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _labReportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Report'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: BlocBuilder<LabReportBloc, LabReportState>(
          builder: (context, state) {
            if (state is LabReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LabReportLoaded) {
              return _buildLabReportView(context, state.labReport);
            } else if (state is LabReportError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchLabReport,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No lab report available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLabReport,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabReportView(BuildContext context, LabReport report) {
    final isPending = report.testResults.any(
      (test) => test.result == 'Pending',
    );

    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(context.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        const Text(
                          'Patient Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPending)
                          Chip(
                            label: const Text('Pending'),
                            backgroundColor: Colors.orange.shade100,
                            avatar: const Icon(
                              Icons.hourglass_empty,
                              color: Colors.orange,
                              size: 16,
                            ),
                          )
                        else
                          Chip(
                            label: const Text('Completed'),
                            backgroundColor: Colors.green.shade100,
                            avatar: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: context.spacingMedium),
                    _buildInfoRow('Name', report.patient.name),
                    _buildInfoRow('Age', '${report.patient.age} years'),
                    _buildInfoRow('Address', report.patient.address),
                    _buildInfoRow(
                      'Lab Result Date',
                      DateFormat('yyyy-MM-dd').format(report.labResultDate),
                    ),
                    _buildInfoRow('Requisition ID', report.id),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spacingLarge),
            const Text(
              'Test Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacingMedium),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(context.spacingXSmall),
                child: Column(
                  children: [
                    Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),

                      columnWidths:
                          MediaQuery.of(context).size.width < 600
                              ? {
                                0: FlexColumnWidth(2),
                                1: IntrinsicColumnWidth(),
                                2: IntrinsicColumnWidth(),
                                3: IntrinsicColumnWidth(),
                              }
                              : {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                              },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFF1A73E8)),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Test Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Result',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Range',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...report.testResults.map((test) {
                          return _buildTestResultRow(test);
                        }),
                      ],
                    ),
                    if (isPending)
                      Padding(
                        padding: EdgeInsets.only(top: context.spacingMedium),
                        child: Container(
                          padding: EdgeInsets.all(context.spacingMedium),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              SizedBox(width: context.spacingSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Waiting for lab results...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(height: context.spacingXSmall),
                                    const Text(
                                      'The lab technician has not submitted the results yet. Please check back later.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!isPending)
                      Padding(
                        padding: EdgeInsets.only(top: context.spacingMedium),
                        child: Container(
                          padding: EdgeInsets.all(context.spacingMedium),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              SizedBox(width: context.spacingSmall),
                              const Text(
                                'Lab results completed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
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

  TableRow _buildTestResultRow(TestResult test) {
    final isPending = test.result == 'Pending';
    final isAbnormal = !isPending && test.isAbnormal;

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(test.testName)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                test.result,
                style: TextStyle(
                  color:
                      isPending
                          ? Colors.grey
                          : (isAbnormal ? Colors.red : Colors.black),
                  fontWeight: isAbnormal ? FontWeight.bold : null,
                ),
              ),
              if (test.unit != null && !isPending)
                Text(
                  ' ${test.unit}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(test.referenceRange),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildStatusIndicator(isPending, isAbnormal),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool isPending, bool isAbnormal) {
    if (isPending) {
      return const Icon(Icons.hourglass_empty, color: Colors.orange, size: 16);
    } else if (isAbnormal) {
      return Tooltip(
        message: 'Abnormal result',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAbnormal ? Icons.warning_amber : Icons.check_circle,
              color: isAbnormal ? Colors.red : Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isAbnormal ? 'Abnormal' : 'Normal',
              style: TextStyle(
                fontSize: 12,
                color: isAbnormal ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return const Icon(Icons.check_circle, color: Colors.green, size: 16);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
