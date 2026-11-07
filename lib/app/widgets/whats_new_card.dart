import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/models/whats_new_model.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';

class WhatsNewCard extends StatelessWidget {
  final WhatsNewModel item;
  // Used by the "See All" grid, which needs the card to fill its grid cell
  // instead of the fixed 0.4-screen-width used by the home rail.
  final bool fullWidth;
  final VoidCallback? onTap;

  const WhatsNewCard({
    super.key,
    required this.item,
    this.fullWidth = false,
    this.onTap,
  });

  TextDirection get _textDirection =>
      item.language.toLowerCase() == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? null : MediaQuery.of(context).size.width * 0.4,
      margin: const EdgeInsetsDirectional.only(end: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap ??
              () => Get.toNamed(AppRoutes.WHATS_NEW_DETAIL, arguments: item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: const Color(0xFFDCD2F7),
                  // Layout direction follows the item's own language rather
                  // than the app's active locale, matching RegularBanner.
                  child: Directionality(
                    textDirection: _textDirection,
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
