import 'package:equatable/equatable.dart';
import 'package:hospital_lab_app/domain/entities/patient.dart';
import 'package:hospital_lab_app/domain/entities/test_result.dart';

class LabReport extends Equatable {
  final String id;
  final Patient patient;
  final DateTime labResultDate;
  final List<TestResult> testResults;
  final String? laboratoryTest; // Add this property

  const LabReport({
    required this.id,
    required this.patient,
    required this.labResultDate,
    required this.testResults,
    this.laboratoryTest,
  });

  @override
  List<Object?> get props => [id, patient, labResultDate, testResults, laboratoryTest];
}

