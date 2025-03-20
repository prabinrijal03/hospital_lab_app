import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hospital_lab_app/domain/entities/requisition.dart';
import 'package:hospital_lab_app/domain/usecases/submit_requisition_usecase.dart';

part 'requisition_event.dart';
part 'requisition_state.dart';

class RequisitionBloc extends Bloc<RequisitionEvent, RequisitionState> {
  final SubmitRequisitionUseCase submitRequisitionUseCase;

  RequisitionBloc({
    required this.submitRequisitionUseCase,
  }) : super(RequisitionInitial()) {
    on<SubmitRequisitionEvent>(_onSubmitRequisition);
  }

  Future<void> _onSubmitRequisition(
    SubmitRequisitionEvent event,
    Emitter<RequisitionState> emit,
  ) async {
    emit(RequisitionSubmitting());
    
    final result = await submitRequisitionUseCase(event.requisition);
    
    result.fold(
      (failure) => emit(RequisitionError(message: failure.message)),
      (id) => emit(RequisitionSubmitSuccess(id: id)),
    );
  }
}

