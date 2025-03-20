import 'package:equatable/equatable.dart';

class TestResult extends Equatable {
  final String testName;
  final String result;
  final String referenceRange;
  final String? unit;

  const TestResult({
    required this.testName,
    required this.result,
    required this.referenceRange,
    this.unit,
  });

  bool get isAbnormal {
    if (result == 'Pending') return false;
    
    // Try to parse numeric values
    try {
      // Handle ranges like "4000 - 11000"
      if (referenceRange.contains('-') || referenceRange.contains('–')) {
        final separator = referenceRange.contains('-') ? '-' : '–';
        final parts = referenceRange.split(separator);
        
        // Extract numeric values, removing any non-numeric characters
        final minStr = parts[0].replaceAll(RegExp(r'[^0-9.]'), '');
        final maxStr = parts[1].replaceAll(RegExp(r'[^0-9.]'), '');
        
        final min = double.parse(minStr);
        final max = double.parse(maxStr);
        
        // Extract numeric value from result
        final resultValue = double.parse(result.replaceAll(RegExp(r'[^0-9.]'), ''));
        
        return resultValue < min || resultValue > max;
      }
      
      // Handle single values (equality check)
      final referenceValue = double.parse(referenceRange.replaceAll(RegExp(r'[^0-9.]'), ''));
      final resultValue = double.parse(result.replaceAll(RegExp(r'[^0-9.]'), ''));
      
      return resultValue != referenceValue;
    } catch (e) {
      // If parsing fails, do a simple string comparison
      return result != referenceRange;
    }
  }

  @override
  List<Object?> get props => [testName, result, referenceRange, unit];
}

