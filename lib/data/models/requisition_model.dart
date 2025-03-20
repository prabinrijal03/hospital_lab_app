import 'package:hospital_lab_app/data/models/patient_model.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';

class RequisitionModel extends Requisition {
  const RequisitionModel({
    required super.id,
    required super.patient,
    required super.laboratoryTest,
    required super.orderDate,
  });

  factory RequisitionModel.fromJson(Map<String, dynamic> json) {
    return RequisitionModel(
      id: json['id'],
      patient: PatientModel.fromJson(json['patient']),
      laboratoryTest: json['laboratoryTest'],
      orderDate: DateTime.parse(json['orderDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': (patient as PatientModel).toJson(),
      'laboratoryTest': laboratoryTest,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}

