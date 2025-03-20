import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';

class SubmitRequisitionUseCase {
  final LabRepository repository;

  SubmitRequisitionUseCase(this.repository);

  Future<Either<Failure, String>> call(Requisition requisition) {
    return repository.submitRequisition(requisition);
  }
}

