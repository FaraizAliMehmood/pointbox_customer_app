import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';

class TransactionsController extends GetxController {
  /// Raw list of all transactions
  final transactions = <Map<String, dynamic>>[].obs;

  /// Current filtered + searched list shown in UI
  final filteredTransactions = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final filterType = 'all'.obs; // all, earn, redeem

  @override
  void onInit() {
    super.onInit();
    _updateNavigationIndex();
    // Initialize filteredTransactions to empty list
    filteredTransactions.value = [];
    loadTransactions();
  }

  void _updateNavigationIndex() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.currentIndex.value = 3;
    }
  }

  /// Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertToMap(dynamic value) {
    if (value == null) {
      return <String, dynamic>{};
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getTransactions();
      print("Transactions API Response: $response");

      if (response['success'] == true && response['data'] != null) {
        final dynamic rawData = response['data'];
        print("Raw data type: ${rawData.runtimeType}");
        print("Raw data: $rawData");

        // Handle both direct list and nested list structures
        List<dynamic> data;
        if (rawData is List) {
          data = rawData;
          print("Data is a direct List with ${data.length} items");
        } else if (rawData is Map) {
          // Convert to Map<String, dynamic> for safe access
          final dataMap = _convertToMap(rawData);
          if (dataMap['transactions'] is List) {
            data = dataMap['transactions'] as List<dynamic>;
            print("Data found in 'transactions' key with ${data.length} items");
          } else if (dataMap['items'] is List) {
            data = dataMap['items'] as List<dynamic>;
            print("Data found in 'items' key with ${data.length} items");
          } else {
            // Fallback: take any list value inside data map
            final firstListEntry = dataMap.values
                .firstWhere(
                  (v) => v is List,
                  orElse: () => <dynamic>[],
                );
            data = firstListEntry is List ? firstListEntry : <dynamic>[];
            print("Data found using fallback with ${data.length} items");
          }
        } else {
          data = <dynamic>[];
          print("Data is not a List or Map, setting to empty");
        }

        if (data.isEmpty) {
          print("No transactions found in response");
          transactions.clear();
          _applyFilters();
          return;
        }

        print("Processing ${data.length} transactions...");
        final mappedTransactions = data.map<Map<String, dynamic>>((rawTx) {
          // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
          final tx = _convertToMap(rawTx);
          print("Processing transaction: ${tx['_id'] ?? tx['id']}");

          // Company / brand info - safely convert
          final companyRaw = tx['company'];
          final company = companyRaw != null ? _convertToMap(companyRaw) : <String, dynamic>{};

          // Type mapping (earn / redeem)
          final rawType = (tx['type'] ?? '').toString().toLowerCase();
          final type = rawType.contains('earn') ? 'earn' : 'redeem';

          // Points: backend uses `redeem_points`
          final rawRedeemPoints = tx['redeem_points'] ?? tx['points'] ?? 0;
          int points;
          if (rawRedeemPoints is int) {
            points = rawRedeemPoints;
          } else {
            points = int.tryParse(rawRedeemPoints.toString()) ?? 0;
          }
          if (type == 'redeem' && points > 0) {
            points = -points;
          }

          // Date parsing: prefer explicit `date`, then `createdAt`
          DateTime? date;
          final rawDate = tx['createdAt'] ?? tx['created_at'] ?? tx['date'];
          if (rawDate is String) {
            date = DateTime.tryParse(rawDate);
          } else if (rawDate is int) {
            date = DateTime.fromMillisecondsSinceEpoch(rawDate);
          }

          return {
            'id': tx['_id'] ?? tx['id'] ?? '',
            'brandName': tx['companyName'] ??
                company['companyName'] ??
                company['name'] ??
                '',
            'brandLogo':
                company['companyLogo'] ?? company['logo'] ?? tx['brandLogo'] ?? '',
            'transactionId': tx['transactionId'] ??
                tx['txnId'] ??
                tx['reference'] ??
                tx['id'] ??
                '',
            'date': date ?? DateTime.now(),
            'description': tx['notes'] ?? tx['description'] ?? '',
            'type': type,
            'points': points,
            'status': (tx['status'] ?? 'Completed').toString(),
            'invoiceNumber': tx['invoiceNumber'] ?? '',
            'invoiceImage': tx['invoiceImage'] ?? '',
            'timeString': tx['time'] ?? '',
            'rawDate': tx['date'] ?? '',
          };
        }).toList();

        transactions.value = mappedTransactions;
        print('Mapped transactions count: ${transactions.length}');
        print('Sample transaction: ${transactions.isNotEmpty ? transactions.first : "none"}');
      } else {
        print("API response indicates failure or no data");
        print("Response success: ${response['success']}");
        print("Response data: ${response['data']}");
        Get.snackbar(
          'error'.tr,
          (response['message'] ?? 'Failed to load transactions').toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
        transactions.clear();
      }

      print("Applying filters...");
      _applyFilters();
      print("Filtered transactions count: ${filteredTransactions.length}");
    } catch (e, stackTrace) {
      print("Error loading transactions: $e");
      print("Stack trace: $stackTrace");
      Get.snackbar(
        'error'.tr,
        'Failed to load transactions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      transactions.clear();
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setFilterType(String type) {
    filterType.value = type;
    _applyFilters();
  }

  void _applyFilters() {
    print("_applyFilters called - transactions count: ${transactions.length}");
    print("Current filter type: ${filterType.value}");
    print("Current search query: '${searchQuery.value}'");
    
    var list = List<Map<String, dynamic>>.from(transactions);
    print("Starting with ${list.length} transactions");

    // Filter by type
    if (filterType.value == 'earn') {
      list = list.where((t) => (t['type'] ?? '') == 'earn').toList();
      print("After 'earn' filter: ${list.length} transactions");
    } else if (filterType.value == 'redeem') {
      list = list.where((t) => (t['type'] ?? '') == 'redeem').toList();
      print("After 'redeem' filter: ${list.length} transactions");
    } else {
      print("No type filter applied (showing all)");
    }

    // Filter by search text (brand name, id, description)
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      final beforeSearch = list.length;
      list = list.where((t) {
        final brandName = (t['brandName'] ?? '').toString().toLowerCase();
        final description = (t['description'] ?? '').toString().toLowerCase();
        final transactionId =
            (t['transactionId'] ?? '').toString().toLowerCase();
        return brandName.contains(query) ||
            description.contains(query) ||
            transactionId.contains(query);
      }).toList();
      print("After search filter '$query': ${list.length} transactions (was $beforeSearch)");
    } else {
      print("No search query applied");
    }

    filteredTransactions.value = list;
    print("Final filtered transactions count: ${filteredTransactions.length}");
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> exportTransactionsCsv() async {
    if (transactions.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'No transactions to export',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln([
        'Transaction ID',
        'Date',
        'Type',
        'Points',
        'Brand',
        'Description',
        'Status',
        'Invoice Number',
      ].join(','));

      // Rows
      for (final tx in transactions) {
        final date = tx['date'] is DateTime ? tx['date'] as DateTime : null;
        final dateStr = date != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(date)
            : (tx['rawDate'] ?? '').toString();

        String escape(String? value) {
          final v = value ?? '';
          final escaped = v.replaceAll('"', '""');
          return '"$escaped"';
        }

        buffer.writeln([
          escape(tx['transactionId']?.toString()),
          escape(dateStr),
          escape((tx['type'] ?? '').toString()),
          escape((tx['points'] ?? '').toString()),
          escape((tx['brandName'] ?? '').toString()),
          escape((tx['description'] ?? '').toString()),
          escape((tx['status'] ?? '').toString()),
          escape((tx['invoiceNumber'] ?? '').toString()),
        ].join(','));
      }

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'PointBox transactions export',
        subject: 'Transactions CSV',
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to export CSV',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }

  void showTransactionDetails(Map<String, dynamic> transaction) {
    final isEarn = (transaction['type'] ?? '') == 'earn';
    final points = transaction['points'] ?? 0;
    final date = transaction['date'] as DateTime?;
    final invoiceNumber = (transaction['invoiceNumber'] ?? '').toString();
    final invoiceImage = (transaction['invoiceImage'] ?? '').toString();
    final brandName = (transaction['brandName'] ?? '').toString();
    final brandLogo = (transaction['brandLogo'] ?? '').toString();
    final description = (transaction['description'] ?? '').toString();
    final status = (transaction['status'] ?? '').toString();
    final transactionId = (transaction['transactionId'] ?? '').toString();

    final dateText = date != null
        ? DateFormat('M/d/yyyy, h:mm:ss a').format(date)
        : (transaction['rawDate'] ?? '').toString();

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transaction ID
                      const Text(
                        'Transaction ID',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactionId,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Type
                      const Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEarn ? 'earn'.tr : 'redeem'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Points
                      const Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${points > 0 ? '+' : ''}$points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: points > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand
                      const Text(
                        'Brand',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child: ClipOval(
                              child: brandLogo.isNotEmpty
                                  ? Image.network(
                                      brandLogo,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.store,
                                      color: Colors.grey[600],
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            brandName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Invoice number
                      if (invoiceNumber.isNotEmpty) ...[
                        const Text(
                          'Invoice Number',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoiceNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Invoice section
                      if (invoiceImage.isNotEmpty) ...[
                        const Text(
                          'Invoice',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(
                              Icons.download_rounded,
                              size: 18,
                              color: Color(0xFF4B2EFF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'View Invoice',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B2EFF),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            invoiceImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

