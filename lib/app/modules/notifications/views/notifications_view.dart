import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pointbox_mobile/app/models/notification_model.dart';
import 'package:pointbox_mobile/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Reload notifications when view is built (e.g., when navigating from push notification)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadNotifications();
    });
    return ResponsiveLayout(
      mobile: Scaffold(
        body: Container(
          decoration: ThemeService.purpleGradient,
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
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
                      ),
                      Expanded(
                        child: Text(
                          'notifications'.tr,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Obx(
                        () => controller.notifications.isNotEmpty
                            ? PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (value) {
                                  if (value == 'mark_all_read') {
                                    controller.markAllAsRead();
                                    Get.snackbar(
                                      'success'.tr,
                                      'all_marked_read'.tr,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else if (value == 'clear_all') {
                                    _showClearAllDialog(context);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'mark_all_read',
                                    child: Text('mark_all_read'.tr),
                                  ),
                                  PopupMenuItem(
                                    value: 'clear_all',
                                    child: Text('clear_all'.tr),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                // Notifications List
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.notifications.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'no_notifications'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.notifications.length,
                          itemBuilder: (context, index) {
                            final notification = controller.notifications[index];
                            return _buildNotificationCard(notification, context);
                          },
                        );
                      },
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

  Widget _buildNotificationCard(NotificationModel notification, BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final isToday = notification.timestamp.day == DateTime.now().day &&
        notification.timestamp.month == DateTime.now().month &&
        notification.timestamp.year == DateTime.now().year;
    
    final timeFormat = isToday
        ? DateFormat('hh:mm a')
        : dateFormat;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.transparent 
              : Theme.of(context).primaryColor.withOpacity(0.3),
          width: notification.isRead ? 0 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
          // Use Get.context to ensure we have the correct context
          final dialogContext = Get.context ?? context;
          _showNotificationDialog(dialogContext, notification);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator or icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? Colors.grey[200]
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: notification.isRead
                      ? Colors.grey[600]
                      : Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and timestamp row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'notification'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Body
                    if (notification.body != null && notification.body!.isNotEmpty)
                      _buildLinkableTextCompact(notification.body!),
                    const SizedBox(height: 8),
                    // Timestamp
                    Text(
                      timeFormat.format(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    // Message Data if available
                    // if (notification.data != null && notification.data!.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 8),
                    //     child: Container(
                    //       padding: const EdgeInsets.all(12),
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey[100],
                    //         borderRadius: BorderRadius.circular(8),
                    //         border: Border.all(color: Colors.grey[300]!),
                    //       ),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Icon(
                    //                 Icons.info_outline,
                    //                 size: 16,
                    //                 color: Colors.grey[700],
                    //               ),
                    //               const SizedBox(width: 4),
                    //               Text(
                    //                 'message_data'.tr,
                    //                 style: TextStyle(
                    //                   fontSize: 12,
                    //                   color: Colors.grey[700],
                    //                   fontWeight: FontWeight.w600,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           const SizedBox(height: 8),
                    //           ...notification.data!.entries.map((entry) {
                    //             return Padding(
                    //               padding: const EdgeInsets.only(bottom: 4),
                    //               child: Row(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     '${entry.key}: ',
                    //                     style: TextStyle(
                    //                       fontSize: 12,
                    //                       color: Colors.grey[800],
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                   Expanded(
                    //                     child: Text(
                    //                       entry.value.toString(),
                    //                       style: TextStyle(
                    //                         fontSize: 12,
                    //                         color: Colors.grey[700],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             );
                    //           }).toList(),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showClearAllDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('clear_all_notifications'.tr),
        content: Text('clear_all_notifications_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllNotifications();
              Get.back();
              Get.snackbar(
                'success'.tr,
                'all_notifications_cleared'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text(
              'clear'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, NotificationModel notification) {
    // Use Get.context to ensure we have the correct navigation context
    final dialogContext = Get.context ?? context;
    
    showDialog(
      context: dialogContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications,
                color: Theme.of(dialogContext).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notification.title ?? 'notification'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.body != null && notification.body!.isNotEmpty)
                  _buildLinkableText(notification.body!)
                else
                  Text(
                    'no_content'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Use Navigator.pop with the dialog context
                Navigator.of(dialogContext).pop();
              },
              child: Text('close'.tr),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinkableTextCompact(String text) {
    // Regular expression to match URLs
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      // No URLs found, return plain text
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Build TextSpan with clickable links
    final textSpans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        );
      }

      // Add clickable URL
      final url = match.group(0)!;
      // Ensure URL has a scheme
      final urlWithScheme = url.startsWith(RegExp(r'https?://|ftp://'))
          ? url
          : 'https://$url';

      textSpans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              try {
                final uri = Uri.parse(urlWithScheme);
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                
                if (!launched) {
                  Get.snackbar(
                    'error'.tr,
                    'Could not open link',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'error'.tr,
                  'Could not open link',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after the last URL
    if (lastEnd < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLinkableText(String text) {
    // Regular expression to match URLs
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      // No URLs found, return plain text
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      );
    }

    // Build TextSpan with clickable links
    final textSpans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        );
      }

      // Add clickable URL
      final url = match.group(0)!;
      // Ensure URL has a scheme
      final urlWithScheme = url.startsWith(RegExp(r'https?://|ftp://'))
          ? url
          : 'https://$url';

      textSpans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              try {
                final uri = Uri.parse(urlWithScheme);
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                
                if (!launched) {
                  Get.snackbar(
                    'error'.tr,
                    'Could not open link',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'error'.tr,
                  'Could not open link',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after the last URL
    if (lastEnd < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}
