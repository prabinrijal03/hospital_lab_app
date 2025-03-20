part of 'requisition_bloc.dart';

abstract class RequisitionEvent extends Equatable {
  const RequisitionEvent();

  @override
  List<Object> get props => [];
}

class SubmitRequisitionEvent extends RequisitionEvent {
  final Requisition requisition;

  const SubmitRequisitionEvent({required this.requisition});

  @override
  List<Object> get props => [requisition];
}

