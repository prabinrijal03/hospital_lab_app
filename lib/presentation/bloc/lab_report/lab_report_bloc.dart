import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hospital_lab_app/domain/entities/lab_report.dart';
import 'package:hospital_lab_app/domain/usecases/get_lab_report_usecase.dart';
import 'package:hospital_lab_app/domain/usecases/submit_lab_report_usecase.dart';

part 'lab_report_event.dart';
part 'lab_report_state.dart';

class LabReportBloc extends Bloc<LabReportEvent, LabReportState> {
  final SubmitLabReportUseCase submitLabReportUseCase;
  final GetLabReportUseCase getLabReportUseCase;

  LabReportBloc({
    required this.submitLabReportUseCase,
    required this.getLabReportUseCase,
  }) : super(LabReportInitial()) {
    on<GetLabReportEvent>(_onGetLabReport);
    on<SubmitLabReportEvent>(_onSubmitLabReport);
  }

  Future<void> _onGetLabReport(
    GetLabReportEvent event,
    Emitter<LabReportState> emit,
  ) async {
    emit(LabReportLoading());
    
    final result = await getLabReportUseCase(event.id);
    
    result.fold(
      (failure) => emit(LabReportError(message: failure.message)),
      (labReport) => emit(LabReportLoaded(labReport: labReport)),
    );
  }

  Future<void> _onSubmitLabReport(
    SubmitLabReportEvent event,
    Emitter<LabReportState> emit,
  ) async {
    emit(LabReportSubmitting());
    
    final result = await submitLabReportUseCase(event.labReport);
    
    result.fold(
      (failure) => emit(LabReportError(message: failure.message)),
      (id) => emit(LabReportSubmitSuccess(id: id)),
    );
  }
}

