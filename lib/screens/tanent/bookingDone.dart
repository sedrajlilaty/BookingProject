import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';

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
    Key? key,
    required this.bookingId,
    required this.apartmentName,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
    this.apartmentLocation = '',
    this.paymentMethod = 'نقدًا',
    this.durationInDays = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'تاكيد الحجز  ',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة النجاح
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: cardBackgroundColor,
              ),
            ),

            const SizedBox(height: 32),

            // نص النجاح
            const Text(
              'تم تأكيد الحجز بنجاح!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'رقم الحجز: $bookingId',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // بطاقة معلومات الحجز

            // نصائح وإرشادات
            Card(
              color: cardBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ماذا بعد؟',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTipItem(
                      Icons.notifications,
                      'ستتلقى تأكيداً عبر البريد الإلكتروني',
                    ),
                    _buildTipItem(
                      Icons.phone,
                      'سيتم التواصل معك من قبل المالك',
                    ),
                    _buildTipItem(
                      Icons.calendar_today,
                      'يمكنك مراجعة حجوزاتك في أي وقت',
                    ),
                    _buildTipItem(Icons.edit, 'يمكنك تعديل الحجز خلال 24 ساعة'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // الأزرار
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // الذهاب لصفحة الحجوزات
                      Navigator.pushReplacementNamed(context, '/my-bookings');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
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
                      // العودة للرئيسية
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'العودة للرئيسية',
                      style: TextStyle(fontSize: 16, color: accentColor),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    // طباعة أو مشاركة التفاصيل
                    _shareBookingDetails(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'مشاركة تفاصيل الحجز',
                        style: TextStyle(color: accentColor),
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
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? accentColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
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
                  // هنا يمكن إضافة منطق المشاركة
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
