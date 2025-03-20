part of 'lab_report_bloc.dart';

abstract class LabReportState extends Equatable {
  const LabReportState();
  
  @override
  List<Object> get props => [];
}

class LabReportInitial extends LabReportState {}

class LabReportLoading extends LabReportState {}

class LabReportLoaded extends LabReportState {
  final LabReport labReport;

  const LabReportLoaded({required this.labReport});

  @override
  List<Object> get props => [labReport];
}

class LabReportSubmitting extends LabReportState {}

class LabReportSubmitSuccess extends LabReportState {
  final String id;

  const LabReportSubmitSuccess({required this.id});

  @override
  List<Object> get props => [id];
}

class LabReportError extends LabReportState {
  final String message;

  const LabReportError({required this.message});

  @override
  List<Object> get props => [message];
}

