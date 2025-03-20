import 'package:hospital_lab_app/data/models/patient_model.dart';
import 'package:hospital_lab_app/data/models/test_result_model.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';

class LabReportModel extends LabReport {
  const LabReportModel({
    required super.id,
    required super.patient,
    required super.labResultDate,
    required super.testResults,
    super.laboratoryTest,
  });

  factory LabReportModel.fromJson(Map<String, dynamic> json) {
    return LabReportModel(
      id: json['id'],
      patient: PatientModel.fromJson(json['patient']),
      labResultDate: DateTime.parse(json['labResultDate']),
      testResults: (json['testResults'] as List)
          .map((e) => TestResultModel.fromJson(e))
          .toList(),
      laboratoryTest: json['laboratoryTest'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': (patient as PatientModel).toJson(),
      'labResultDate': labResultDate.toIso8601String(),
      'testResults': testResults
          .map((e) => (e as TestResultModel).toJson())
          .toList(),
      'laboratoryTest': laboratoryTest,
    };
  }
}

