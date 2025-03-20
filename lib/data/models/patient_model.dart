import 'package:hospital_lab_app/domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.name,
    required super.age,
    required super.address,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      name: json['name'],
      age: json['age'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'address': address,
    };
  }
}

