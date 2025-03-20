import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/presentation/pages/doctor/doctor_home_page.dart';
import 'package:hospital_lab_app/presentation/pages/doctor/lab_report_view_page.dart';
import 'package:hospital_lab_app/presentation/pages/doctor/requisition_history_page.dart';
import 'package:hospital_lab_app/presentation/pages/lab/lab_report_page.dart';
import 'package:hospital_lab_app/presentation/pages/role_selection_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorHomePage(),
      ),
      GoRoute(
        path: '/doctor/history',
        builder: (context, state) => const RequisitionHistoryPage(),
      ),
      GoRoute(
        path: '/doctor/report/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LabReportViewPage(requisitionId: id);
        },
      ),
      GoRoute(
        path: '/lab',
        builder: (context, state) => const LabReportPage(),
      ),
      GoRoute(
        path: '/lab/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LabReportPage(initialRequisitionId: id);
        },
      ),
    ],
  );
}

