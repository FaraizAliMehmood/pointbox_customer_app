import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ThemeService.purpleGradient,
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: actions,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Use maybePop for better compatibility - it safely pops if possible
                  Navigator.of(context).maybePop().then((popped) {
                    // If maybePop didn't pop (returned false), use Get.back() as fallback
                    if (!popped) {
                      Get.back();
                    }
                  }).catchError((_) {
                    // If Navigator fails, use Get.back()
                    Get.back();
                  });
                },
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

