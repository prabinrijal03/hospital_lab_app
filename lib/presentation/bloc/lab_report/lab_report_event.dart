part of 'lab_report_bloc.dart';

abstract class LabReportEvent extends Equatable {
  const LabReportEvent();

  @override
  List<Object> get props => [];
}

class GetLabReportEvent extends LabReportEvent {
  final String id;

  const GetLabReportEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class SubmitLabReportEvent extends LabReportEvent {
  final LabReport labReport;

  const SubmitLabReportEvent({required this.labReport});

  @override
  List<Object> get props => [labReport];
}

