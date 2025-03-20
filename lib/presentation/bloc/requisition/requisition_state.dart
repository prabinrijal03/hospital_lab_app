part of 'requisition_bloc.dart';

abstract class RequisitionState extends Equatable {
  const RequisitionState();
  
  @override
  List<Object> get props => [];
}

class RequisitionInitial extends RequisitionState {}

class RequisitionSubmitting extends RequisitionState {}

class RequisitionSubmitSuccess extends RequisitionState {
  final String id;

  const RequisitionSubmitSuccess({required this.id});

  @override
  List<Object> get props => [id];
}

class RequisitionError extends RequisitionState {
  final String message;

  const RequisitionError({required this.message});

  @override
  List<Object> get props => [message];
}

