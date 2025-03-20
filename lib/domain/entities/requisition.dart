import 'package:equatable/equatable.dart';
import 'package:hospital_lab_app/domain/entities/patient.dart';

class Requisition extends Equatable {
  final String id;
  final Patient patient;
  final String? laboratoryTest;
  final DateTime orderDate;
  
  const Requisition({
    required this.id,
    required this.patient,
    required this.laboratoryTest,
    required this.orderDate,
  });
  
  @override
  List<Object?> get props => [id, patient, laboratoryTest, orderDate];
}

