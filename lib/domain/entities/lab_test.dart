import 'package:equatable/equatable.dart';

class LabTest extends Equatable {
  final String testName;
  final String referenceRange;
  final String? unit;

  const LabTest({
    required this.testName,
    required this.referenceRange,
    this.unit,
  });

  @override
  List<Object?> get props => [testName, referenceRange, unit];
}

