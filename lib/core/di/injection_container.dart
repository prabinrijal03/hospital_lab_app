import 'package:get_it/get_it.dart';
import 'package:hospital_lab_app/data/repositories/lab_repository_impl.dart';
import 'package:hospital_lab_app/domain/repositories/lab_repository.dart';
import 'package:hospital_lab_app/domain/usecases/get_lab_report_usecase.dart';
import 'package:hospital_lab_app/domain/usecases/submit_lab_report_usecase.dart';
import 'package:hospital_lab_app/domain/usecases/submit_requisition_usecase.dart';
import 'package:hospital_lab_app/presentation/bloc/lab_report/lab_report_bloc.dart';
import 'package:hospital_lab_app/presentation/bloc/requisition/requisition_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => RequisitionBloc(
      submitRequisitionUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => LabReportBloc(
      submitLabReportUseCase: sl(),
      getLabReportUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitRequisitionUseCase(sl()));
  sl.registerLazySingleton(() => SubmitLabReportUseCase(sl()));
  sl.registerLazySingleton(() => GetLabReportUseCase(sl()));

  // Repository
  sl.registerLazySingleton<LabRepository>(() => LabRepositoryImpl());
  sl.registerLazySingleton<LabRepositoryImpl>(() => LabRepositoryImpl());
}

