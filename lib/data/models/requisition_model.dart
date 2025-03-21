import 'package:hospital_lab_app/data/models/lab_test_model.dart';
import 'package:hospital_lab_app/data/models/patient_model.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';

class RequisitionModel extends Requisition {
  const RequisitionModel({
    required super.id,
    required super.patient,
    required super.labTests,
    required super.orderDate,
    super.laboratoryTest,
  });

  factory RequisitionModel.fromJson(Map<String, dynamic> json) {
    return RequisitionModel(
      id: json['id'],
      patient: PatientModel.fromJson(json['patient']),
      labTests: json['labTests'] != null
          ? (json['labTests'] as List)
              .map((e) => LabTestModel.fromJson(e))
              .toList()
          : [],
      orderDate: DateTime.parse(json['orderDate']),
      laboratoryTest: json['laboratoryTest'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': (patient as PatientModel).toJson(),
      'labTests': labTests.map((e) => (e as LabTestModel).toJson()).toList(),
      'orderDate': orderDate.toIso8601String(),
      'laboratoryTest': laboratoryTest,
    };
  }
}

