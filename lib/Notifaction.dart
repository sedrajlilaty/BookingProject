import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../constants.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is DarkState;

        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            title: Text(
              isDark ? 'المفضلة' : 'Favorites',
              style: const TextStyle(
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
          ),


          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNotificationItem(
                isDark,
                icon: Icons.check_circle_outline,
                title: 'تم تأكيد الحجز',
                subtitle: 'تم تأكيد حجزك بنجاح',
                time: 'منذ 10 دقائق',
              ),
              _buildNotificationItem(
                isDark,
                icon: Icons.schedule,
                title: 'حجز قيد المراجعة',
                subtitle: 'المالك يراجع طلب الحجز',
                time: 'منذ ساعة',
              ),
              _buildNotificationItem(
                isDark,
                icon: Icons.notifications_active_outlined,
                title: 'عرض خاص',
                subtitle: 'خصم 20% على الحجوزات الطويلة',
                time: 'أمس',
              ),
              _buildNotificationItem(
                isDark,
                icon: Icons.warning_amber_outlined,
                title: 'تنبيه',
                subtitle: 'يرجى إكمال بيانات الحساب',
                time: 'منذ يومين',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      bool isDark, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String time,
      }) {
    return Card(
      color: isDark ? Colors.grey[800] : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accentColor.withOpacity(0.15),
          child: Icon(icon, color: accentColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
