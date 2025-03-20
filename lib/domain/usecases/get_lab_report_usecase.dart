import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';

class GetLabReportUseCase {
  final LabRepository repository;

  GetLabReportUseCase(this.repository);

  Future<Either<Failure, LabReport>> call(String id) {
    return repository.getLabReport(id);
  }
}

