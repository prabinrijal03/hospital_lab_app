import 'package:flutter/material.dart';
import 'package:hospital_lab_app/core/extensions/theme_extension.dart';

/// Extension on Widget to add common styling and spacing
extension WidgetExtension on Widget {
  // Add padding
  Widget withPadding(EdgeInsetsGeometry padding) => Padding(
    padding: padding,
    child: this,
  );
  
  // Add margin
  Widget withMargin(EdgeInsetsGeometry margin) => Container(
    margin: margin,
    child: this,
  );
  
  // Add card styling
  Widget asCard(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: context.borderRadiusMedium,
    ),
    child: this,
  );
  
  // Center the widget
  Widget centered() => Center(child: this);
  
  // Add a border
  Widget withBorder(BuildContext context, {Color? color, double width = 1.0}) => Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: color ?? context.primaryColor,
        width: width,
      ),
      borderRadius: context.borderRadiusMedium,
    ),
    child: this,
  );
  
  // Add a shadow
  Widget withShadow({
    Color color = Colors.black26,
    double blurRadius = 10.0,
    Offset offset = const Offset(0, 2),
  }) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          offset: offset,
        ),
      ],
    ),
    child: this,
  );
}

