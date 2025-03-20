import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_lab_app/presentation/widgets/responsive_container.dart';
import 'package:hospital_lab_app/presentation/widgets/app_drawer.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Lab App'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: ResponsiveContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select your role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.go('/doctor'),
                icon: const Icon(Icons.medical_services),
                label: const Text('Doctor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/lab'),
                icon: const Icon(Icons.science),
                label: const Text('Lab Technician'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Complete Workflow:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildWorkflowStep(
                      '1',
                      'Doctor creates lab requisition',
                      Icons.medical_services,
                    ),
                    const SizedBox(height: 8),
                    _buildWorkflowStep(
                      '2',
                      'Lab technician enters test results',
                      Icons.science,
                    ),
                    const SizedBox(height: 8),
                    _buildWorkflowStep(
                      '3',
                      'Doctor views completed lab report',
                      Icons.description,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWorkflowStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}

