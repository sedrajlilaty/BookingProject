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
    final now = DateTime.now();
    final allBookings = bookingProvider.bookings;
    // 1. الحجوزات المعلقة كما هي
    final pendingBookings =
        allBookings.where((b) => b.status == BookingStatus.pending).toList();

    // 2. الحجوزات المؤكدة (فقط التي لم ينتهِ تاريخها بعد)
    final confirmedBookings =
        allBookings.where((b) {
          bool isConfirmedStatus = b.status == BookingStatus.confirmed;
          bool isNotExpired = b.endDate.isAfter(now); // التاريخ لم ينتهِ بعد
          return isConfirmedStatus && isNotExpired;
        }).toList();

    // 3. الحجوزات المكتملة (الحالات المكتملة رسمياً + الحالات المؤكدة التي انتهى تاريخها)
    final completedBookings =
        allBookings.where((b) {
          bool isCompletedStatus = b.status == BookingStatus.completed;
          bool isExpiredConfirmed =
              (b.status == BookingStatus.confirmed && b.endDate.isBefore(now));
          return isCompletedStatus || isExpiredConfirmed;
        }).toList();

    // 4. الحجوزات الملغية كما هي
    final cancelledBookings =
        allBookings.where((b) => b.status == BookingStatus.cancelled).toList();
    // جلب القائمة الكلية من البروفايدر

    // تقسيم الحجوزات حسب الحالة بناءً على الـ Enum
    /* final pendingBookings =
        allBookings.where((b) => b.status == BookingStatus.pending).toList();
    final confirmedBookings =
        allBookings.where((b) => b.status == BookingStatus.confirmed).toList();
    final completedBookings =
        allBookings.where((b) => b.status == BookingStatus.completed).toList();
    final cancelledBookings =
        allBookings.where((b) => b.status == BookingStatus.cancelled).toList();
*/
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
            "There is no booking yet..",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("start your first booking"),
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
                                apartment?.name ?? "loading name..",
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
                                          : "loading location..",
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
                        _buildDateItem("from", booking.startDate),
                        _buildDateItem("to", booking.endDate),
                        _buildPriceItem(booking.totalPrice),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 5. أزرار التحكم بناءً على حالة الحجز
                    // 5. أزرار التحكم بناءً على حالة الحجز
                    // 5. أزرار التحكم بناءً على حالة الحجز والتاريخ
                    Row(
                      children: [
                        // تعريف متغير للتحقق مما إذا كان الحجز قد انتهى زمنياً
                        (() {
                          final isExpired = booking.endDate.isBefore(
                            DateTime.now(),
                          );
                          final isConfirmed =
                              booking.status == BookingStatus.confirmed;
                          final isCompleted =
                              booking.status == BookingStatus.completed;

                          // الحالة الأولى: إذا كان الحجز "مكتمل" أو "مؤكد وانتهى تاريخه"
                          // في هذه الحالة نعرض أزرار التقييم فقط
                          if (isCompleted || (isConfirmed && isExpired)) {
                            return Expanded(
                              child: Row(
                                children: [
                                  // زر عرض التقييمات
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          () => _showApartmentGeneralRatings(
                                            booking.apartmentId,
                                          ),
                                      icon: const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      label: const Text("Reviews"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.amber[900],
                                        side: BorderSide(
                                          color: Colors.amber[700]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // زر إضافة تقييم
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _rateApartment(booking),
                                      icon: const Icon(
                                        Icons.add_comment,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Rate Now",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // الحالة الثانية: حجز مؤكد أو معلق ولم ينتهِ تاريخه بعد
                          // نعرض أزرار التعديل والإلغاء
                          if ((booking.status == BookingStatus.pending ||
                                  isConfirmed) &&
                              !isExpired) {
                            return Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          () => _cancelBooking(booking.id),
                                      icon: const Icon(Icons.close, size: 14),
                                      label: const Text("Cancel"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
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
                                        "Edit",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // الحالة الثالثة: بانتظار مراجعة التعديل
                          if (booking.status == BookingStatus.pendingUpdate) {
                            return Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Modification under review...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          // الحالة الرابعة: حجز ملغي
                          if (booking.status == BookingStatus.cancelled) {
                            return const Expanded(
                              child: Center(
                                child: Text(
                                  "This booking is canceled",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        }()),
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
        const Text("total", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            title: const Text(" confirm cancle"),
            content: const Text(
              "are you sure you want to cancle this booking?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("no"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  " confirm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && authProvider.token != null) {
      await bookingProvider.cancelUserBooking(bookingId, authProvider.token!);
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

  void _rateApartment(Booking booking) async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // إذا كان المستخدم قد قيم مسبقاً، نجلب التقييم من السيرفر ونعرضه
    if (booking.hasRated) {
      // إظهار مؤشر تحميل بسيط
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // جلب بيانات التقييم من السيرفر باستخدام apartmentId
        await bookingProvider.getApartmentRating(booking.apartmentId);

        Navigator.pop(context); // إغلاق مؤشر التحميل

        // الانتقال لصفحة عرض التقييم (سنفترض وجود سكرين بهذا الاسم)
        // أو يمكنك استخدام نفس صفحة التقييم مع تمرير مود العرض فقط
        _showRatingDetailsSheet(bookingProvider.currentApartmentRating);
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("فشل جلب بيانات التقييم: $e")));
      }
      return;
    }

    // المنطق الأصلي في حال لم يتم التقييم بعد (فتح واجهة التقييم)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RateApartmentScreen(
              booking: booking,
              onRatingSubmitted: (rating, review) async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                try {
                  await bookingProvider.submitReview(
                    bookingId: booking.id,
                    rating: rating,
                    comment: review,
                    token: authProvider.token!,
                  );
                  // بعد النجاح، نحدث الحجوزات ليتغير الزر إلى "Show Rating"
                  bookingProvider.fetchUserBookings(authProvider.token!);
                } catch (e) {
                  // يجب أن يكون السطر هنا بالداخل
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
      ),
    );
  }

  void _showRatingDetailsSheet(Map<String, dynamic>? data) {
    if (data == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Apartment Rating",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 40),
                  const SizedBox(width: 10),
                  Text(
                    "${data['average_rating']}", // القيمة القادمة من السيرفر
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " / 5",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Total Reviews: ${data['total_reviews']}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApartmentGeneralRatings(dynamic apartmentId) async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // إظهار Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // جلب بيانات التقييم العامة للشقة
      await bookingProvider.getApartmentRating(apartmentId);

      Navigator.pop(context); // إغلاق الـ Loading

      // عرض النتائج في الـ BottomSheet الذي قمت ببرمجته مسبقاً
      _showRatingDetailsSheet(bookingProvider.currentApartmentRating);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching reviews: $e")));
    }
  }
}
