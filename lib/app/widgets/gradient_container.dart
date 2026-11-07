import 'package:flutter/material.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ThemeService.purpleGradient,
      padding: padding,
      child: child,
    );
  }
}

