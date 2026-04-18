import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../di/injection.dart';
import '../../../routes/route_names.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final controller = dependencies.notificationController;
    final quranController = dependencies.quranController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: <Widget>[
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.items.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'read') {
                    await controller.markAllRead();
                    return;
                  }
                  if (value == 'clear') {
                    await controller.clearAll();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'read',
                    child: Text('Tandai semua dibaca'),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Text('Hapus semua'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.loading) {
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  height: 110,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            }

            if (controller.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 72,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada notifikasi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Pengingat adzan, daily ayah, dan update aplikasi akan tampil di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(
                    title: item.title,
                    body: item.body,
                    time: _formatTime(item),
                    color: _colorForCategory(item.category),
                    icon: _iconForCategory(item.category),
                    read: item.read,
                    onTap: () async {
                      await controller.markRead(item.id);
                      if (!context.mounted) return;
                      final routeName = item.routeName;
                      if ((routeName ?? '').isEmpty) return;

                      if (routeName == RouteNames.reader &&
                          item.routeIntArgument != null) {
                        final surah = quranController
                            .surahs()
                            .where((entry) =>
                                entry.number == item.routeIntArgument)
                            .firstOrNull;
                        if (surah != null) {
                          Navigator.of(context).pushNamed(
                            RouteNames.reader,
                            arguments: surah,
                          );
                        }
                        return;
                      }

                      final argument = controller.routeArgumentFor(item);
                      Navigator.of(context)
                          .pushNamed(routeName!, arguments: argument);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTime(item) {
    final time = item.scheduledAt ?? item.createdAt;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'adzan':
        return Icons.schedule_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'daily_ayah':
        return Icons.auto_awesome_rounded;
      case 'update':
        return Icons.update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'adzan':
        return AppColors.primary;
      case 'reminder':
        return AppColors.secondary;
      case 'daily_ayah':
        return AppColors.tertiary;
      case 'update':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: read ? Colors.white.withValues(alpha: 0.84) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: read
              ? null
              : Border.all(color: color.withValues(alpha: 0.18), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        time,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: const TextStyle(
                      height: 1.5,
                      color: AppColors.textSecondary,
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
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
