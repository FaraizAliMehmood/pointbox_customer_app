import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Clamps [text] to 3 lines and shows a "Read More" link when it overflows.
class DescriptionWithReadMore extends StatelessWidget {
  final String text;
  final TextStyle style;
  final VoidCallback onReadMore;

  const DescriptionWithReadMore({
    super.key,
    required this.text,
    required this.style,
    required this.onReadMore,
  });

  static const int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: style,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onReadMore,
                child: Text(
                  'read_more'.tr,
                  style: style.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
