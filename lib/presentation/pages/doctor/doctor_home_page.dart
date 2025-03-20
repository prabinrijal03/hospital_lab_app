import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/core/di/injection_container.dart';
import 'package:hospital_lab_app/core/extensions/button_entension.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';
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
  final _testController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _testController.dispose();
    super.dispose();
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
                      Text(
                        'Lab Test Information',
                        style: context.headingMedium,
                      ),
                      SizedBox(height: context.spacingMedium),
                      TextFormField(
                        controller: _testController,
                        decoration: const InputDecoration(
                          labelText: 'Laboratory Test',
                          hintText: 'e.g. Total leucocyte count',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter laboratory test';
                          }
                          return null;
                        },
                      ),
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
                            if (_formKey.currentState!.validate()) {
                              final requisition = RequisitionModel(
                                id: const Uuid().v4(),
                                patient: PatientModel(
                                  name: _nameController.text,
                                  age: int.parse(_ageController.text),
                                  address: _addressController.text,
                                ),
                                laboratoryTest: _testController.text,
                                orderDate: DateTime.now(),
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
                      SizedBox(height: context.spacingMedium),
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
                  // Navigate back to role selection page
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
