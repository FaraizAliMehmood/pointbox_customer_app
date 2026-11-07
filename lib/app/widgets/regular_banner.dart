import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pointbox_mobile/app/models/banner_model.dart';
import 'package:pointbox_mobile/app/widgets/banner_detail_page.dart';
import 'package:pointbox_mobile/app/widgets/description_with_read_more.dart';

class RegularBanner extends StatelessWidget {
  final BannerModel banner;

  const RegularBanner({
    super.key,
    required this.banner,
  });

  TextDirection get _textDirection =>
      banner.language.toLowerCase() == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 12),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFf6339a), // pink-400
            Color(0xFF9810fa), // purple-500
            Color(0xFF4f39f6), // purple-600
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _handleBannerTap(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          // Layout direction follows the banner's own language rather than
          // the app's active locale, since each banner can be authored in
          // either English or Arabic independently of the app UI.
          child: Directionality(
            textDirection: _textDirection,
            child: Row(
            children: [
              // Left side - Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge - show if available
                    if (banner.badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              banner.badge,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (banner.badge.isNotEmpty) const SizedBox(height: 12),
                    // Title
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Description - clamped to 3 lines, with Read More if it overflows
                    DescriptionWithReadMore(
                      text: banner.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      onReadMore: () =>
                          Get.to(() => BannerDetailPage(banner: banner)),
                    ),
                    if (banner.points > 0) ...[
                      const SizedBox(height: 12),
                      // Points indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${banner.points} points',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right side - Image from imageUrl
              if (banner.imageUrl.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Fallback icon if no imageUrl
                Center(
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBannerTap(BuildContext context) async {
    if (banner.productUrl != null && banner.productUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(banner.productUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open link: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
