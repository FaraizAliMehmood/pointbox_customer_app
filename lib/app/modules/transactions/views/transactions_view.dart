import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:pointbox_mobile/app/widgets/bottom_nav_bar.dart';
import 'package:pointbox_mobile/app/widgets/gradient_app_bar.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: GradientAppBar(title: 'transaction_history'.tr),
        body: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => await controller.loadTransactions(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // _buildHeaderCard(context),
                  const SizedBox(height: 16),
                  _buildSearchAndFilters(context),
                  const SizedBox(height: 16),
                  if (controller.filteredTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'no_transactions'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...controller.filteredTransactions
                        .map(
                          (transaction) =>
                              _buildTransactionCard(context, transaction),
                        )
                        .toList(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}

Widget _buildHeaderCard(BuildContext context) {
  final controller = Get.find<TransactionsController>();

  return GestureDetector(
    onTap: () => controller.exportTransactionsCsv(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Color(0xFF4B2EFF),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSearchAndFilters(BuildContext context) {
  final controller = Get.find<TransactionsController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.updateSearchQuery,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'search'.tr,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Obx(
        () => Row(
          children: [
            _FilterChipButton(
              label: 'filter'.tr,
              isSelected: controller.filterType.value == 'all',
              onTap: () => controller.setFilterType('all'),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: 'earn'.tr,
              isSelected: controller.filterType.value == 'earn',
              onTap: () => controller.setFilterType('earn'),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: 'redeem'.tr,
              isSelected: controller.filterType.value == 'redeem',
              onTap: () => controller.setFilterType('redeem'),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTransactionCard(
    BuildContext context, Map<String, dynamic> transaction) {
  final isEarn = (transaction['type'] ?? '') == 'earn';
  final points = transaction['points'] ?? 0;
  final date = transaction['date'] as DateTime?;
  final controller = Get.find<TransactionsController>();

  final badgeColor =
      isEarn ? const Color(0xFFD9FFEA) : const Color(0xFFFFE1E1);
  final badgeTextColor =
      isEarn ? const Color(0xFF00B36A) : const Color(0xFFE53935);

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: (transaction['brandLogo'] ?? '')
                          .toString()
                          .isNotEmpty
                      ? Image.network(
                          transaction['brandLogo'],
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.store,
                          color: Colors.grey[600],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (transaction['brandName'] ?? '').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (transaction['transactionId'] ?? '').toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isEarn ? 'earn'.tr : 'redeem'.tr,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (date != null)
                    Text(
                      controller.formatDate(date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    (transaction['description'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${points > 0 ? '+' : ''}$points',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: points > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (transaction['status'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.showTransactionDetails(transaction),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'View',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4B2EFF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF4B2EFF) : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

