import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';// تأكد من مسار ThemeCubit

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('hh:mm a');
    final duration = booking.endDate.difference(booking.startDate).inDays;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        // ألوان حسب الثيم
        Color backgroundColor = isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color secondaryTextColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'تفاصيل الحجز',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة الحجز الرئيسية
                Card(
                  color: cardColor,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.apartmentName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(booking.status)),
                              ),
                              child: Text(
                                _getStatusText(booking.status),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.apartmentLocation,
                          style: TextStyle(fontSize: 14, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // معلومات الحجز
                Text('معلومات الحجز',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                _buildInfoRow('رقم الحجز', booking.id, textColor, secondaryTextColor),
                _buildInfoRow('تاريخ الحجز', dateFormat.format(booking.bookingDate), textColor, secondaryTextColor),
                _buildInfoRow('وقت الحجز', timeFormat.format(booking.bookingDate), textColor, secondaryTextColor),

                const SizedBox(height: 20),

                // التواريخ
                Text('تواريخ الإقامة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateCard('بداية الحجز', booking.startDate, isDark),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    _buildDateCard('نهاية الحجز', booking.endDate, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('مدة الإقامة', '$duration يوم', textColor, secondaryTextColor),

                const SizedBox(height: 20),

                // المعلومات المالية
                Text('المعلومات المالية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                _buildInfoRow('السعر اليومي', '\$${booking.pricePerDay.toStringAsFixed(2)}', textColor, secondaryTextColor),
                _buildInfoRow('إجمالي السعر', '\$${booking.totalPrice.toStringAsFixed(2)}', textColor, secondaryTextColor),
                _buildInfoRow('طريقة الدفع', booking.paymentMethod, textColor, secondaryTextColor),

                const SizedBox(height: 20),

                // تقييم المستخدم
                if (booking.hasRated)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تقييمك للشقة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 12),
                      Card(
                        color: isDark ? Colors.grey[700] : Colors.amber[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  for (int i = 0; i < 5; i++)
                                    Icon(
                                      i < (booking.userRating ?? 0).round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${booking.userRating}/5',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (booking.userReview != null && booking.userReview!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    booking.userReview!,
                                    style: TextStyle(fontSize: 14, color: textColor),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                // أزرار الإجراءات
                if (booking.status == BookingStatus.confirmed &&
                    booking.endDate.isAfter(DateTime.now()))
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('تعديل الحجز'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: const Text('إلغاء الحجز'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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

  Widget _buildInfoRow(String label, String value, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: secondaryTextColor)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime date, bool isDark) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Expanded(
      child: Card(
        color: isDark ? Colors.grey[700] : Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300]! : Colors.blue)),
              const SizedBox(height: 4),
              Text(dateFormat.format(date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.pending:
        return 'قيد المراجعة';
      case BookingStatus.cancelled:
        return 'ملغى';
      case BookingStatus.completed:
        return 'مكتمل';
    }
  }
}
