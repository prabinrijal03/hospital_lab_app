import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/core/extensions/button_entension.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';
import 'package:hospital_lab_app/data/models/lab_test_model.dart';
import 'package:hospital_lab_app/data/models/patient_model.dart';
import 'package:hospital_lab_app/data/models/requisition_model.dart';
import 'package:hospital_lab_app/presentation/bloc/requisition/requisition_bloc.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:uuid/uuid.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  // store test entries
  final List<LabTestEntry> _labTests = [];

  @override
  void initState() {
    super.initState();
    _addLabTest();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();

    for (var test in _labTests) {
      test.dispose();
    }

    super.dispose();
  }

  void _addLabTest() {
    setState(() {
      _labTests.add(
        LabTestEntry(
          testNameController: TextEditingController(),
          referenceRangeController: TextEditingController(),
          unitController: TextEditingController(),
        ),
      );
    });
  }

  void _removeLabTest(int index) {
    setState(() {
      _labTests[index].dispose();
      _labTests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RequisitionBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Requisition Form'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => context.go('/doctor/history'),
              tooltip: 'View Requisition History',
            ),
          ],
        ),
        body: BlocConsumer<RequisitionBloc, RequisitionState>(
          listener: (context, state) {
            if (state is RequisitionSubmitSuccess) {
              _showRequisitionSuccessDialog(context, state.id);
            } else if (state is RequisitionError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is RequisitionSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ResponsiveContainer(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.spacingMedium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Information', style: context.headingMedium),
                      SizedBox(height: context.spacingMedium),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name',
                          hintText: 'e.g. Jung Bahadur Rana',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacingMedium),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Age',
                          hintText: 'e.g. 60',
                          border: OutlineInputBorder(),
                          suffixText: 'years',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacingMedium),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Address',
                          hintText: 'e.g. Hanuman Dhoka',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lab Test Information',
                            style: context.headingMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: context.successColor,
                            onPressed: _addLabTest,
                            tooltip: 'Add another test',
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacingMedium),
                      ..._buildLabTestForms(),
                      SizedBox(height: context.spacingMedium),
                      TextFormField(
                        initialValue: DateTime.now().toString().split(' ')[0],
                        decoration: const InputDecoration(
                          labelText: 'Lab Order Date',
                          border: OutlineInputBorder(),
                          helperText: 'Current date is automatically selected',
                        ),
                        readOnly: true,
                      ),
                      SizedBox(height: context.spacingXLarge),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _validateLabTests()) {
                              final labTests =
                                  _labTests.map((entry) {
                                    return LabTestModel(
                                      testName: entry.testNameController.text,
                                      referenceRange:
                                          entry.referenceRangeController.text,
                                      unit:
                                          entry.unitController.text.isNotEmpty
                                              ? entry.unitController.text
                                              : null,
                                    );
                                  }).toList();

                              final requisition = RequisitionModel(
                                id: const Uuid().v4(),
                                patient: PatientModel(
                                  name: _nameController.text,
                                  age: int.parse(_ageController.text),
                                  address: _addressController.text,
                                ),
                                labTests: labTests,
                                orderDate: DateTime.now(),
                                laboratoryTest:
                                    labTests.isNotEmpty
                                        ? labTests.first.testName
                                        : null,
                              );

                              context.read<RequisitionBloc>().add(
                                SubmitRequisitionEvent(
                                  requisition: requisition,
                                ),
                              );
                            }
                          },
                          style: context.primaryButtonStyle,
                          child: const Text(
                            'Submit Requisition',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
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

  List<Widget> _buildLabTestForms() {
    return List.generate(_labTests.length, (index) {
      final entry = _labTests[index];
      return Card(
        margin: EdgeInsets.only(bottom: context.spacingMedium),
        child: Padding(
          padding: EdgeInsets.all(context.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Test ${index + 1}', style: context.headingSmall),
                  if (_labTests.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeLabTest(index),
                      tooltip: 'Remove test',
                    ),
                ],
              ),
              SizedBox(height: context.spacingMedium),
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
              ),
              SizedBox(height: context.spacingMedium),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: entry.referenceRangeController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Range',
                        hintText: 'e.g. 4000 – 11000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reference range';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: context.spacingMedium),
                  Expanded(
                    child: TextFormField(
                      controller: entry.unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g. /microliter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  bool _validateLabTests() {
    if (_labTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one lab test')),
      );
      return false;
    }

    for (var test in _labTests) {
      if (test.testNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all test names')),
        );
        return false;
      }
      if (test.referenceRangeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all reference ranges')),
        );
        return false;
      }
    }

    return true;
  }

  void _showRequisitionSuccessDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Requisition Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your lab requisition has been submitted successfully. Please share this ID with the lab technician:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: context.spacingMedium),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: context.borderRadiusMedium,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(id, style: context.headingSmall)),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Requisition ID copied to clipboard',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/doctor/report/$id');
                },
                style: context.successButtonStyle,
                child: const Text('View Lab Report'),
              ),
            ],
          ),
    );
  }
}

class LabTestEntry {
  final TextEditingController testNameController;
  final TextEditingController referenceRangeController;
  final TextEditingController unitController;

  LabTestEntry({
    required this.testNameController,
    required this.referenceRangeController,
    required this.unitController,
  });

  void dispose() {
    testNameController.dispose();
    referenceRangeController.dispose();
    unitController.dispose();
  }
}
