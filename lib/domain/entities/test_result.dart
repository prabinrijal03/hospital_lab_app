import 'package:equatable/equatable.dart';

class TestResult extends Equatable {
  final String testName;
  final String result;
  final String referenceRange;
  
  const TestResult({
    required this.testName,
    required this.result,
    required this.referenceRange,
  });
  
  @override
  List<Object?> get props => [testName, result, referenceRange];
}

