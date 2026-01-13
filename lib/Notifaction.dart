import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/notificationProvider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../constants.dart';
// تأكد من المسار
// تأكد من المسار

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // جلب الإشعارات عند فتح الصفحة
    Future.delayed(Duration.zero, () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(auth.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notiProvider = Provider.of<NotificationProvider>(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is DarkState;

        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'الإشعارات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: accentColor,
            centerTitle: true,
            elevation: 4,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: [
              // زر قراءة الكل
              if (notiProvider.notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  onPressed: () => notiProvider.markAllAsRead(auth.token!),
                  tooltip: 'تحديد الكل كمقروء',
                ),
            ],
          ),
          body:
              notiProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notiProvider.notifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                    onRefresh:
                        () => notiProvider.fetchNotifications(auth.token!),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          notiProvider.notifications
                              .where((n) => !n.isRead)
                              .length,
                      itemBuilder: (context, index) {
                        // جلب الإشعارات غير المقروءة فقط
                        final unreadNotifications =
                            notiProvider.notifications
                                .where((n) => !n.isRead)
                                .toList();
                        final item = unreadNotifications[index];

                        return _buildNotificationItem(
                          isDark,
                          item: item,
                          token: auth.token!,
                        );
                      },
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    bool isDark, {
    required dynamic item,
    required String token,
  }) {
    return InkWell(
      onTap: () {
        if (!item.isRead) {
          // إذا لم يكن مقروءاً بالفعل
          // نقوم باستدعاء الدالة وتمرير الـ ID والتوكن
          context.read<NotificationProvider>().markAsRead(item.id, token);
        }
      },
      child: Card(
        color:
            item.isRead
                ? (isDark ? Colors.grey[850] : Colors.white)
                : (isDark ? Colors.blueGrey[900] : Colors.blue[50]),
        elevation: item.isRead ? 1 : 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              item.isRead
                  ? BorderSide.none
                  : BorderSide(color: accentColor.withOpacity(0.3), width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor:
                item.isRead
                    ? Colors.grey[400]!.withOpacity(0.2)
                    : accentColor.withOpacity(0.15),
            child: Icon(
              item.isRead
                  ? Icons.notifications_none
                  : Icons.notifications_active,
              color: item.isRead ? Colors.grey : accentColor,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.body,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeago.format(item.createdAt, locale: 'ar'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات حالياً',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
