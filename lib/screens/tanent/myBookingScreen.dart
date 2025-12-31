import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/models/booking_model.dart';

import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/screens/tanent/booking_details_screen.dart';
import 'package:flutter_application_8/screens/tanent/edit_booking_screen.dart';
import 'package:flutter_application_8/screens/tanent/rate_apartment_screen.dart';
import 'package:intl/intl.dart';



// أنواع الفلترة
enum BookingFilter { all, current, completed, cancelled, pending }

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  BookingFilter _selectedFilter = BookingFilter.all;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // الحصول على حجوزات المستخدم الحالي فقط
    final userBookings = bookingProvider.getUserBookings(
      authProvider.user?.id ?? '',
    );

    // فلترة الحجوزات حسب الاختيار
    final filteredBookings = _filterBookings(userBookings);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'غير مسجل الدخول',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'يرجى تسجيل الدخول لعرض حجوزاتك',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حجوزاتي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
        elevation: 4,
        actions: [
          PopupMenuButton<BookingFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            itemBuilder:
                (context) => [
              const PopupMenuItem(
                value: BookingFilter.all,
                child: Text('عرض الكل'),
              ),
              const PopupMenuItem(
                value: BookingFilter.current,
                child: Text('الحجوزات الحالية'),
              ),
              const PopupMenuItem(
                value: BookingFilter.completed,
                child: Text('الحجوزات المكتملة'),
              ),
              const PopupMenuItem(
                value: BookingFilter.pending,
                child: Text('الحجوزات قيد المراجعة'),
              ),
              const PopupMenuItem(
                value: BookingFilter.cancelled,
                child: Text('الحجوزات الملغية'),
              ),
            ],
          ),
        ],
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: Column(
        children: [
          // شريط الفلترة السريع
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    BookingFilter.values.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            _getFilterText(filter),
                            style: TextStyle(
                              color:
                                  _selectedFilter == filter
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          selected: _selectedFilter == filter,
                          selectedColor: accentColor,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // عداد الحجوزات
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد الحجوزات: ${filteredBookings.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_selectedFilter == BookingFilter.all)
                  Text(
                    'الإجمالي: ${userBookings.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),

          // قائمة الحجوزات
          Expanded(
            child:
                filteredBookings.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getEmptyStateIcon(),
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyStateText(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return BookingCard(
                          booking: booking,
                          onTap: () => _showBookingDetails(context, booking),
                          onCancel: () => _cancelBooking(context, booking),
                          onEdit: () => _editBooking(context, booking),
                          onRate: () => _rateApartment(context, booking),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // ✅ **الدالة المفقودة 1: عرض تفاصيل الحجز**
  void _showBookingDetails(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }

  // ✅ **الدالة المفقودة 2: إلغاء الحجز**
  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الإلغاء'),
            content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('تراجع'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                child: const Text('نعم، إلغاء'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      bookingProvider.updateBookingStatus(booking.id, BookingStatus.cancelled);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الحجز بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✅ **الدالة المفقودة 3: تعديل الحجز**
  void _editBooking(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditBookingScreen(
              booking: booking,
              onBookingUpdated: (updatedBooking) {
                final bookingProvider = Provider.of<BookingProvider>(
                  context,
                  listen: false,
                );
                // هنا تحتاج لدالة updateBooking في BookingProvider
              },
            ),
      ),
    );
  }

  // ✅ **الدالة المفقودة 4: تقييم الشقة**
  void _rateApartment(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RateApartmentScreen(
              booking: booking,
              onRatingSubmitted: (rating, review) {
                final bookingProvider = Provider.of<BookingProvider>(
                  context,
                  listen: false,
                );
                bookingProvider.updateBookingRating(booking.id, rating, review);
              },
            ),
      ),
    );
  }

  // 📊 **دوال مساعدة**
  List<Booking> _filterBookings(List<Booking> bookings) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case BookingFilter.current:
        return bookings.where((b) => b.isCurrent).toList();
      case BookingFilter.completed:
        return bookings.where((b) => b.isCompleted).toList();
      case BookingFilter.cancelled:
        return bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      case BookingFilter.pending:
        return bookings
            .where((b) => b.status == BookingStatus.pending)
            .toList();
      case BookingFilter.all:
      default:
        return bookings;
    }
  }

  String _getFilterText(BookingFilter filter) {
    switch (filter) {
      case BookingFilter.all:
        return 'الكل';
      case BookingFilter.current:
        return 'الحالية';
      case BookingFilter.completed:
        return 'المكتملة';
      case BookingFilter.cancelled:
        return 'الملغية';
      case BookingFilter.pending:
        return 'قيد المراجعة';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case BookingFilter.current:
        return Icons.calendar_today;
      case BookingFilter.completed:
        return Icons.history;
      case BookingFilter.cancelled:
        return Icons.cancel;
      case BookingFilter.pending:
        return Icons.pending;
      case BookingFilter.all:
      default:
        return Icons.book_online;
    }
  }

  String _getEmptyStateText() {
    switch (_selectedFilter) {
      case BookingFilter.current:
        return 'لا توجد حجوزات حالية';
      case BookingFilter.completed:
        return 'لا توجد حجوزات مكتملة';
      case BookingFilter.cancelled:
        return 'لا توجد حجوزات ملغية';
      case BookingFilter.pending:
        return 'لا توجد حجوزات قيد المراجعة';
      case BookingFilter.all:
      default:
        return 'لا توجد حجوزات';
    }
  }
}

// ✅ **تحديث BookingCard Widget**
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final VoidCallback onRate;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onCancel,
    required this.onEdit,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isPastBooking = booking.endDate.isBefore(DateTime.now());
    final canEdit = booking.status == BookingStatus.confirmed ||!isPastBooking;
    final canRate = booking.isCompleted || !booking.hasRated;
    final canCancel =
        (booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.pending) &&
        !isPastBooking;

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          // معلومات الحجز
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة الشقة
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/apartment_placeholder.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // تفاصيل الحجز
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.apartmentName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  booking.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(booking.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(booking.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.apartmentLocation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'السعر: \$${booking.totalPrice.toStringAsFixed(2)}',
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
                ],
              ),
            ),
          ),

          // أزرار الإجراءات
          if (canEdit || canCancel || canRate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // زر التعديل
                  if (canEdit)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('تعديل'),
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                    ),

                  // زر الإلغاء
                  if (canCancel)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('إلغاء'),
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                    ),

                  // زر التقييم
                  if (canRate)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('تقييم'),

                      onPressed: onRate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 227, 184, 24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                    ),
                ],
              ),
            ),
        ],
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
        return accentColor;
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
