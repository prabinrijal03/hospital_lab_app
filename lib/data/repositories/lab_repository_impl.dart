import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/data/models/lab_report_model.dart';
import 'package:hospital_lab_app/data/models/test_result_model.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';

class LabRepositoryImpl implements LabRepository {
  // In-memory storage for demo purposes
  final Map<String, Requisition> _requisitions = {};
  final Map<String, LabReport> _labReports = {};

  // Method to get all requisitions for the history page
  List<Requisition> getRequisitions() {
    return _requisitions.values.toList();
  }
  
  // Method to get a specific requisition
  Requisition? getRequisition(String id) {
    return _requisitions[id];
  }
  
  // Method to check if a lab report exists
  bool hasLabReport(String id) {
    return _labReports.containsKey(id);
  }
  
  // Method to get all lab reports
  List<LabReport> getLabReports() {
    return _labReports.values.toList();
  }

  @override
  Future<Either<Failure, String>> submitRequisition(Requisition requisition) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _requisitions[requisition.id] = requisition;
      return Right(requisition.id);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to submit requisition'));
    }
  }

  @override
  Future<Either<Failure, String>> submitLabReport(LabReport labReport) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _labReports[labReport.id] = labReport;
      return Right(labReport.id);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to submit lab report'));
    }
  }

  @override
  Future<Either<Failure, LabReport>> getLabReport(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, if the lab report doesn't exist yet, create a placeholder
      if (!_labReports.containsKey(id)) {
        final requisition = _requisitions[id];
        if (requisition == null) {
          return const Left(CacheFailure(message: 'Requisition not found'));
        }
        
        // Create an empty lab report based on the requisition
        final labReport = LabReportModel(
          id: id,
          patient: requisition.patient,
          labResultDate: DateTime.now(),
          testResults: [
            TestResultModel(
              testName: requisition.laboratoryTest ?? 'Total leucocyte count',
              result: 'Pending',
              referenceRange: '4000 – 11000/microliter',
            ),
          ],
        );
        
        return Right(labReport);
      }
      
      return Right(_labReports[id]!);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get lab report'));
    }
  }
}

