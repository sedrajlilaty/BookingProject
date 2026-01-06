import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/providers/appartementProvider.dart';
import 'package:flutter_application_8/screens/tanent/edit_booking_screen.dart';
import 'package:flutter_application_8/screens/tanent/rate_apartment_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/models/booking_model.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات من السيرفر عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        Provider.of<BookingProvider>(
          context,
          listen: false,
        ).fetchUserBookings(auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // جلب القائمة الكلية من البروفايدر
    final allBookings = bookingProvider.bookings;

    // تقسيم الحجوزات حسب الحالة بناءً على الـ Enum
    final pendingBookings =
        allBookings.where((b) => b.status == BookingStatus.pending).toList();
    final confirmedBookings =
        allBookings.where((b) => b.status == BookingStatus.confirmed).toList();
    final completedBookings =
        allBookings.where((b) => b.status == BookingStatus.completed).toList();
    final cancelledBookings =
        allBookings.where((b) => b.status == BookingStatus.cancelled).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "My Booking",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: accentColor,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            // لون النص للتبويب المختار حالياً
            labelColor: Colors.white,
            // لون النص للتبويبات غير المختارة
            unselectedLabelColor: Colors.white70,
            // ستايل الخط للتبويب المختار
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            // ستايل الخط للتبويبات غير المختارة
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "waiting.."),
              Tab(text: "confirmed"),
              Tab(text: "Done"),
              Tab(text: "canceled"),
            ],
          ),
        ),
        body:
            bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    _buildBookingList(pendingBookings, authProvider.token!),
                    _buildBookingList(confirmedBookings, authProvider.token!),
                    _buildBookingList(completedBookings, authProvider.token!),
                    _buildBookingList(cancelledBookings, authProvider.token!),
                  ],
                ),
      ),
    );
  }

  // بناء قائمة الحجوزات لكل تاب
  Widget _buildBookingList(List<Booking> bookings, String token) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().fetchUserBookings(token),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "لا توجد حجوزات حالياً",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("ابحث عن شقة وابدأ حجزك الأول!"),
        ],
      ),
    );
  }

  // بناء كارد الحجز
  Widget _buildBookingCard(Booking booking) {
    // استخدام Consumer للوصول إلى بيانات الشقق و AuthProvider للتوكن
    return Consumer2<ApartmentProvider, AuthProvider>(
      builder: (context, aptProv, authProv, child) {
        return FutureBuilder<Apartment?>(
          // جلب تفاصيل الشقة بناءً على المعرف المخزن في الحجز
          // داخل MyBookingsScreen
          // داخل MyBookingsScreen في سطر 133
          future: aptProv.fetchApartmentById(booking.apartmentId),
          builder: (context, snapshot) {
            final apartment = snapshot.data;

            return Card(
              color: cardBackgroundColor,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // 1. عرض صورة الشقة (أو أيقونة مؤقتة في حال التحميل)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              apartment != null && apartment.images.isNotEmpty
                                  ? Image.network(
                                    apartment.images[0],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  )
                                  : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 12),

                        // 2. معلومات الشقة (الاسم والمدينة)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment?.name ?? "جاري تحميل الاسم...",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      apartment != null
                                          ? "${apartment.city}, ${apartment.governorate}"
                                          : "جاري تحميل الموقع...",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. شارة الحالة (Badge)
                        _buildStatusBadge(booking.status),
                      ],
                    ),

                    const Divider(height: 30),

                    // 4. عرض التواريخ والسعر الإجمالي
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateItem("من", booking.startDate),
                        _buildDateItem("إلى", booking.endDate),
                        _buildPriceItem(booking.totalPrice),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 5. أزرار التحكم بناءً على حالة الحجز
                    Row(
                      children: [
                        // 1. إظهار أزرار (إلغاء وتعديل) إذا كان الحجز معلقاً أو مؤكداً
                        // أزرار التحكم: تظهر في حالة Pending أو Confirmed
                        if (booking.status == BookingStatus.pending ||
                            booking.status == BookingStatus.confirmed) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _cancelBooking(booking.id),
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text("إلغاء"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _modifyBooking(booking),
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "تعديل",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                              ),
                            ),
                          ),
                        ],

                        // إذا كان مؤكداً، يمكنك إبقاء زر التواصل أيضاً كخيار إضافي
                        if (booking.status == BookingStatus.confirmed) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                /* منطق التواصل */
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                "تواصل",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],

                        // 3. حالة بانتظار الموافقة على التعديل (Pending Update)
                        if (booking.status == BookingStatus.pendingUpdate)
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "طلب التعديل قيد المراجعة...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // 4. حالة الحجز المكتمل (Completed)
                        if (booking.status == BookingStatus.completed)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rateApartment(booking),
                              icon: Icon(
                                booking.hasRated
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.white,
                              ),
                              label: Text(
                                booking.hasRated
                                    ? "عرض تقييمك"
                                    : "تقييم الإقامة",
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    booking.hasRated
                                        ? Colors.blueGrey
                                        : Colors.amber[700],
                              ),
                            ),
                          ),

                        // 5. حالة الحجز الملغي (Cancelled)
                        if (booking.status == BookingStatus.cancelled)
                          const Expanded(
                            child: Center(
                              child: Text(
                                "تم إلغاء هذا الحجز",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
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
      },
    );
  }

  Widget _buildDateItem(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          "${date.day}/${date.month}/${date.year}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPriceItem(double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "الإجمالي",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          "${price.toStringAsFixed(0)} ر.س",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: accentColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String text;

    switch (status) {
      case BookingStatus.confirmed:
        color = Colors.green;
        text = "confirmed"; // Confirmed
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = "cancelled"; // Cancelled
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        text = "completed"; // Completed
        break;
      case BookingStatus.pendingUpdate:
        color = Colors.deepOrange;
        text = "pending update"; // Pending modification approval
        break;
      case BookingStatus.pending:
      default:
        color = Colors.orange;
        text = "pending"; // Waiting for initial approval
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // زيادة الشفافية قليلاً للوضوح
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ), // إضافة إطار خفيف
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == BookingStatus.pendingUpdate ||
              status == BookingStatus.pending)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(dynamic bookingId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("تأكيد الإلغاء"),
            content: const Text("هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("تراجع"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "تأكيد الإلغاء",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && authProvider.token != null) {
      await bookingProvider.handleBookingAction(
        bookingId,
        'cancel',
        authProvider.token!,
      );
      // تحديث القائمة بعد الإلغاء
      bookingProvider.fetchUserBookings(authProvider.token!);
    }
  }

  void _modifyBooking(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditBookingScreen(
              booking: booking,
              onBookingUpdated: (updatedBooking) {
                // هنا نقوم باستدعاء البروفايدر لتحديث البيانات في السيرفر أو القائمة المحلية
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                // افترضنا وجود دالة تحديث في البروفايدر الخاص بك
                /* context.read<BookingProvider>().updateBooking(
                  updatedBooking,
                  authProvider.token!,
                );*/
              },
            ),
      ),
    );
  }

  void _rateApartment(Booking booking) {
    if (booking.hasRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لقد قمت بتقييم هذه الشقة مسبقاً")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RateApartmentScreen(
              booking: booking,
              onRatingSubmitted: (rating, review) {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                // استدعاء دالة التقييم في البروفايدر
                /* context.read<BookingProvider>().submitReview(
                bookingId: booking.id,
                rating: rating,
                comment: review,
                token: authProvider.token!,
              );*/
              },
            ),
      ),
    );
  }
}
