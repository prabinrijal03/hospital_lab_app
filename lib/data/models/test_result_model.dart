import 'package:hospital_lab_app/domain/entities/test_result.dart';

class TestResultModel extends TestResult {
  const TestResultModel({
    required super.testName,
    required super.result,
    required super.referenceRange,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      testName: json['testName'],
      result: json['result'],
      referenceRange: json['referenceRange'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'result': result,
      'referenceRange': referenceRange,
    };
  }
}

