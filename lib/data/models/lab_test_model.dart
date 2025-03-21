import 'package:hospital_lab_app/domain/entities/lab_test.dart';

class LabTestModel extends LabTest {
  const LabTestModel({
    required super.testName,
    required super.referenceRange,
    super.unit,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      testName: json['testName'],
      referenceRange: json['referenceRange'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'referenceRange': referenceRange,
      'unit': unit,
    };
  }
}

