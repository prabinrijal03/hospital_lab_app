import 'package:equatable/equatable.dart';
import 'package:hospital_lab_app/domain/entities/lab_test.dart';
import 'package:hospital_lab_app/domain/entities/patient.dart';

class Requisition extends Equatable {
  final String id;
  final Patient patient;
  final List<LabTest> labTests;
  final DateTime orderDate;
  final String? laboratoryTest;

  const Requisition({
    required this.id,
    required this.patient,
    required this.labTests,
    required this.orderDate,
    this.laboratoryTest,
  });

  @override
  List<Object?> get props => [id, patient, labTests, orderDate, laboratoryTest];
}

