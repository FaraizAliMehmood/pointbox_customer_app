import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pointbox_mobile/app/models/banner_model.dart';
import 'package:pointbox_mobile/app/widgets/banner_detail_page.dart';
import 'package:pointbox_mobile/app/widgets/description_with_read_more.dart';

class SpecialEventBanner extends StatelessWidget {
  final BannerModel banner;

  const SpecialEventBanner({
    super.key,
    required this.banner,
  });

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        // Banner content comes from the backend in English, so keep its
        // layout LTR (image on the right, text starting on the left)
        // regardless of the app's active locale.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
          children: [
            // Left side - Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge - always show, use banner badge or default
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
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          banner.badge.isNotEmpty ? banner.badge : 'Limited Time Offer',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  // Claim button
               banner.productUrl != null ? InkWell(
                    onTap: () => _handleBannerTap(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:  const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 18,
                            color: const Color(0xFF7C3AED),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Claim the offer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : const SizedBox.shrink(),
                ],
              ),
            ),
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
                        Icons.card_giftcard,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Fallback icon if no imageUrl
           const   Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    Icons.card_giftcard,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBannerTap(BuildContext context) async {
    if (banner.productUrl != null && banner.productUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(banner.productUrl!);
        // Launch URL directly - LaunchMode.externalApplication opens in external browser
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
