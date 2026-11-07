import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pointbox_mobile/app/modules/brands/controllers/brands_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/bottom_nav_bar.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class BrandsView extends GetView<BrandsController> {
  const BrandsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        body: Container(
          decoration: ThemeService.purpleGradient,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brands',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4)
                    ],
                  ),
                ),
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: controller.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'search'.tr,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter Buttons
                      Obx(
                        () => Row(
                          children: [
                            _buildFilterButton(
                              'all_brands'.tr,
                              'all',
                              controller.filterType.value == 'all',
                              () => controller.setFilterType('all'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterButton(
                              'linked_brands'.tr,
                              'linked',
                              controller.filterType.value == 'linked',
                              () => controller.setFilterType('linked'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterButton(
                              'unlinked'.tr,
                              'unlinked',
                              controller.filterType.value == 'unlinked',
                              () => controller.setFilterType('unlinked'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Brands Grid
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Obx(
                      () {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        // Show error state if there's an error
                        if (controller.error.value.isNotEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.error.value,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () => controller.loadBrands(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7C3AED),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        // Show empty state if no brands
                        if (controller.filteredBrands.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'no_brands'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Show brands grid
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: controller.filteredBrands.length,
                            itemBuilder: (context, index) {
                              final brand = controller.filteredBrands[index];
                              return _buildBrandCard(context, brand);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF7C3AED),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _countryIconPath(String country) {
    final slug = country.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return 'assets/images/$slug.png';
  }

  Widget _buildBrandCard(BuildContext context, Map<String, dynamic> brand) {
    final isLinked = brand['linked'] == true;
    final logoUrl = (brand['companyLogo'] ?? brand['logo'])?.toString() ?? '';
    final hasLogo = logoUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo image area
            Expanded(
              child: Stack(
                children: [
                  if (hasLogo)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        color: Colors.grey[200],
                      ),
                    ),

                  // Top-right green tick for linked brands
                  if (isLinked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),

                  // Top purple "Link Brand" button only when not linked
                  if (!isLinked)
                    Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: () => controller.linkBrand(brand['id']),
                        child: Container(
                          height: 30,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Link Brand',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom-left country flag overlay on the image
                  if ((brand['country'] ?? '').toString().isNotEmpty)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: Image.asset(
                          _countryIconPath(
                            (brand['country'] ?? '').toString(),
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.flag,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Name below the image
            Container(
              width: double.infinity,
              color: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                brand['name'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
