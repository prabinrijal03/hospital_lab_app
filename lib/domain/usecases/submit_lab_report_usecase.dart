import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';

class SubmitLabReportUseCase {
  final LabRepository repository;

  SubmitLabReportUseCase(this.repository);

  Future<Either<Failure, String>> call(LabReport labReport) {
    return repository.submitLabReport(labReport);
  }
}

