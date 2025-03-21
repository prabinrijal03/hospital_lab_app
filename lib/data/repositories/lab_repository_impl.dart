import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hospital_lab_app/core/error/failures.dart';
import 'package:hospital_lab_app/data/models/lab_report_model.dart';
import 'package:hospital_lab_app/data/models/patient_model.dart';
import 'package:hospital_lab_app/data/models/requisition_model.dart';
import 'package:hospital_lab_app/data/models/test_result_model.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabRepositoryImpl implements LabRepository {
  final SharedPreferences sharedPreferences;
  
  static const String _requisitionsKey = 'requisitions';
  static const String _labReportsKey = 'lab_reports';
  
  LabRepositoryImpl({required this.sharedPreferences});
  
  // get all requisitions
  List<Requisition> getRequisitions() {
    final requisitionsJson = sharedPreferences.getString(_requisitionsKey);
    if (requisitionsJson == null) return [];
    
    final List<dynamic> decodedList = json.decode(requisitionsJson);
    return decodedList.map((item) => RequisitionModel.fromJson(item)).toList();
  }
  
  // get a specific requisition
  Requisition? getRequisition(String id) {
    final requisitions = getRequisitions();
    try {
      return requisitions.firstWhere(
        (req) => req.id == id,
        orElse: () => throw Exception('Requisition not found'),
      );
    } catch (e) {
      return null;
    }
  }
  
  // check if lab report exists
  bool hasLabReport(String id) {
    try {
      final report = _getLabReportFromStorage(id);
      if (report == null) return false;
      
      return report.testResults.any((test) => test.result != 'Pending');
    } catch (e) {
      return false;
    }
  }
  
  // get all lab reports
  List<LabReport> getLabReports() {
    final labReportsJson = sharedPreferences.getString(_labReportsKey);
    if (labReportsJson == null) return [];
    
    final Map<String, dynamic> decodedMap = json.decode(labReportsJson);
    return decodedMap.values
        .map((item) => LabReportModel.fromJson(item))
        .toList();
  }
  
  // get lab report from storage
  LabReportModel? _getLabReportFromStorage(String id) {
    final labReportsJson = sharedPreferences.getString(_labReportsKey);
    if (labReportsJson == null) return null;
    
    final Map<String, dynamic> decodedMap = json.decode(labReportsJson);
    if (!decodedMap.containsKey(id)) return null;
    
    return LabReportModel.fromJson(decodedMap[id]);
  }
  
  // save requisitions to storage
  Future<void> _saveRequisitionsToStorage(List<RequisitionModel> requisitions) async {
    final List<Map<String, dynamic>> jsonList = 
        requisitions.map((req) => req.toJson()).toList();
    await sharedPreferences.setString(_requisitionsKey, json.encode(jsonList));
  }
  
  // save lab report to storage
  Future<void> _saveLabReportToStorage(LabReportModel report) async {
    final labReportsJson = sharedPreferences.getString(_labReportsKey);
    Map<String, dynamic> labReports = {};
    
    if (labReportsJson != null) {
      labReports = json.decode(labReportsJson);
    }
    
    labReports[report.id] = report.toJson();
    await sharedPreferences.setString(_labReportsKey, json.encode(labReports));
  }

  @override
  Future<Either<Failure, String>> submitRequisition(Requisition requisition) async {
    try {
      final requisitions = getRequisitions().toList();
      
      requisitions.add(requisition as RequisitionModel);
      
      await _saveRequisitionsToStorage(
        requisitions.cast<RequisitionModel>()
      );
      
      return Right(requisition.id);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to submit requisition: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> submitLabReport(LabReport labReport) async {
    try {
      await _saveLabReportToStorage(labReport as LabReportModel);
      
      return Right(labReport.id);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to submit lab report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LabReport>> getLabReport(String id) async {
    try {
      final labReport = _getLabReportFromStorage(id);
      
      if (labReport == null) {
        try {
          final requisition = getRequisition(id);
          if (requisition == null) {
            return const Left(CacheFailure(message: 'Requisition not found'));
          }
          
          final testResults = <TestResultModel>[];
          
          if (requisition.labTests.isNotEmpty) {
            testResults.addAll(
              requisition.labTests.map((test) => TestResultModel(
                testName: test.testName,
                result: 'Pending',
                referenceRange: test.referenceRange,
                unit: test.unit,
              )),
            );
          } else if (requisition.laboratoryTest != null) {
            testResults.add(
              const TestResultModel(
                testName: 'Total leucocyte count',
                result: 'Pending',
                referenceRange: '4000 – 11000',
                unit: '/microliter',
              ),
            );
          }
          
          final newLabReport = LabReportModel(
            id: id,
            patient: requisition.patient as PatientModel,
            labResultDate: DateTime.now(),
            laboratoryTest: requisition.laboratoryTest,
            testResults: testResults,
          );
          
          await _saveLabReportToStorage(newLabReport);
          
          return Right(newLabReport);
        } catch (e) {
          return Left(CacheFailure(message: 'Failed to create lab report: ${e.toString()}'));
        }
      }
      
      return Right(labReport);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get lab report: ${e.toString()}'));
    }
  }
}

