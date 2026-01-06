import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../owner/homePage.dart' show ApartmentBookingScreen;
import 'myBookingScreen.dart' show MyBookingsScreen;
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

class BookingDone extends StatelessWidget {
  final String bookingId;
  final String apartmentName;
  final String apartmentLocation;
  final double totalPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String paymentMethod;
  final int durationInDays;

  const BookingDone({
    super.key,
    required this.bookingId,
    required this.apartmentName,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
    this.apartmentLocation = '',
    this.paymentMethod = 'نقدًا',
    this.durationInDays = 1,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : Colors.black;
        Color accent = accentColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'تاكيد الحجز',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: accent,
            centerTitle: true,
            elevation: 4,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, size: 80, color: cardColor),
                ),
                const SizedBox(height: 32),
                Text(
                  'تم طلب الحجز بانتظار موافقة المالك',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'رقم الحجز: $bookingId',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ماذا بعد؟',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accent,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTipItem(
                          Icons.notifications,
                          'ستتلقى تأكيداً عبر البريد الإلكتروني',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.phone,
                          'سيتم التواصل معك من قبل المالك',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.calendar_today,
                          'يمكنك مراجعة حجوزاتك في أي وقت',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.edit,
                          'يمكنك تعديل الحجز خلال 24 ساعة',
                          accent,
                          textColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyBookingsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'عرض حجوزاتي',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ApartmentBookingScreen(isOwner: false),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: accent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'العودة للرئيسية',
                          style: TextStyle(fontSize: 16, color: accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _shareBookingDetails(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, size: 20, color: accent),
                          const SizedBox(width: 8),
                          Text(
                            'مشاركة تفاصيل الحجز',
                            style: TextStyle(color: accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipItem(
    IconData icon,
    String text,
    Color accent,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
          ),
        ],
      ),
    );
  }

  void _shareBookingDetails(BuildContext context) {
    final details = '''
تم تأكيد حجزك بنجاح!

رقم الحجز: $bookingId
اسم الشقة: $apartmentName
تاريخ الوصول: ${DateFormat('yyyy-MM-dd').format(checkInDate)}
تاريخ المغادرة: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}
المبلغ الإجمالي: \$${totalPrice.toStringAsFixed(2)}

شكراً لاستخدامك تطبيقنا!
''';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تفاصيل الحجز'),
            content: SingleChildScrollView(child: Text(details)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ التفاصيل للحافظة')),
                  );
                },
                child: const Text('نسخ التفاصيل'),
              ),
            ],
          ),
    );
  }
}
