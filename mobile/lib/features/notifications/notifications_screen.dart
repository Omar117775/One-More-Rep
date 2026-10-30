import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

enum NotificationType { training, subscription, achievement, announcement }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  bool read;
}

/// Standalone Notifications Center with training reminders,
/// subscription alerts, achievements, and read/unread state management.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      title: 'Time to Train: Upper Body Phalanx',
      body: 'Your scheduled Spartan chest and arm workout begins today at 6:00 PM.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      type: NotificationType.training,
      read: false,
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Warrior Achievement Unlocked!',
      body: 'You earned "Spartan Discipline" for maintaining a 7-day streak.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.achievement,
      read: false,
    ),
    AppNotification(
      id: 'notif-3',
      title: 'Subscription Status: Active',
      body: 'Your Spartan Pro subscription is active with 26 days remaining.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.subscription,
      read: true,
    ),
    AppNotification(
      id: 'notif-4',
      title: 'Arena Announcement: New Workouts Added',
      body: 'Check out 6 new Spartan training programs in the catalog.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.announcement,
      read: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.read = true;
      }
    });
  }

  void _toggleRead(AppNotification item) {
    setState(() {
      item.read = !item.read;
    });
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.training => Icons.fitness_center,
      NotificationType.achievement => Icons.emoji_events,
      NotificationType.subscription => Icons.verified_user,
      NotificationType.announcement => Icons.campaign,
    };
  }

  Color _colorForType(NotificationType type) {
    return switch (type) {
      NotificationType.training => AppColors.metallicGold,
      NotificationType.achievement => AppColors.success,
      NotificationType.subscription => AppColors.metallicBronze,
      NotificationType.announcement => AppColors.neutralGray,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: Text(strings.notificationsTitle),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                strings.notificationsMarkAllRead,
                style: AppText.secondary.copyWith(
                  color: AppColors.metallicGold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMax,
            ),
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: AppColors.neutralGray,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(strings.notificationsEmpty, style: AppText.secondary),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final color = _colorForType(item.type);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: OmrCard(
                          onTap: () => _toggleRead(item),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.16),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Icon(
                                  _iconForType(item.type),
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: AppText.title.copyWith(
                                              fontSize: 14,
                                              fontWeight: item.read
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (!item.read)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.metallicGold,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.body,
                                      style: AppText.body.copyWith(
                                        color: item.read
                                            ? AppColors.neutralGray
                                            : AppColors.warmWhite,
                                        fontSize: 12.5,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
