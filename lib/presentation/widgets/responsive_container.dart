import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool adaptivePadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.adaptivePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: padding ?? 
            (adaptivePadding 
              ? EdgeInsets.all(isSmallScreen ? 8.0 : 16.0)
              : const EdgeInsets.all(16.0)),
          child: child,
        ),
      ),
    );
  }
}

