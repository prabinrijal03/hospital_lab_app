import 'package:flutter/material.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';

extension ButtonExtension on BuildContext {
  // Primary button
  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    elevation: 2,
  );
  
  // Secondary button 
  ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    elevation: 2,
  );
  
  // Outlined button 
  ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    side: BorderSide(color: primaryColor),
  );
  
  // Success button 
  ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: successColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    elevation: 2,
  );
  
  // Warning button 
  ButtonStyle get warningButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: warningColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    elevation: 2,
  );
  
  // Error button
  ButtonStyle get errorButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusMedium,
    ),
    elevation: 2,
  );
  
  // Icon button
  ButtonStyle get iconButtonStyle => IconButton.styleFrom(
    foregroundColor: primaryColor,
    shape: const CircleBorder(),
  );
}

