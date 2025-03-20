import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';

abstract class LabRepository {
  Future<Either<Failure, String>> submitRequisition(Requisition requisition);
  Future<Either<Failure, String>> submitLabReport(LabReport labReport);
  Future<Either<Failure, LabReport>> getLabReport(String id);
}

