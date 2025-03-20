import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  // Colors
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get errorColor => Theme.of(this).colorScheme.error;
  
  // Custom app colors
  Color get successColor => const Color(0xFF4CAF50);
  Color get warningColor => const Color(0xFFFFA000);
  Color get infoColor => const Color(0xFF2196F3);
  
  // Background colors for status indicators
  Color get successBackgroundColor => const Color(0xFFE8F5E9);
  Color get warningBackgroundColor => const Color(0xFFFFF8E1);
  Color get errorBackgroundColor => const Color(0xFFFFEBEE);
  Color get infoBackgroundColor => const Color(0xFFE3F2FD);
  
  // Text styles
  TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get headingSmall => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
  );
  
  TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
  );
  
  TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
  );
  
  // Spacing
  double get spacingXSmall => 4.0;
  double get spacingSmall => 8.0;
  double get spacingMedium => 16.0;
  double get spacingLarge => 24.0;
  double get spacingXLarge => 32.0;
  
  // Border radius
  BorderRadius get borderRadiusSmall => BorderRadius.circular(4.0);
  BorderRadius get borderRadiusMedium => BorderRadius.circular(8.0);
  BorderRadius get borderRadiusLarge => BorderRadius.circular(12.0);
  BorderRadius get borderRadiusXLarge => BorderRadius.circular(16.0);
}

