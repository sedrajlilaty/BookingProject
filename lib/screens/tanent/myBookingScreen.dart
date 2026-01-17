import 'package:flutter/material.dart';
import 'package:flutter_application_8/Theme/theme_cubit.dart';
import 'package:flutter_application_8/Theme/theme_state.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/providers/appartementProvider.dart';
import 'package:flutter_application_8/screens/tanent/edit_booking_screen.dart';
import 'package:flutter_application_8/screens/tanent/rate_apartment_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final loc = AppLocalizations.of(context)!;

    // جلب حالة الثيم لاستخراج الألوان
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.white;

        final now = DateTime.now();
        final allBookings = bookingProvider.bookings;

        final pendingBookings = allBookings.where((b) => b.status == BookingStatus.pending).toList();
        
        final confirmedBookings = allBookings.where((b) {
          return b.status == BookingStatus.confirmed && b.endDate.isAfter(now);
        }).toList();

        final completedBookings = allBookings.where((b) {
          bool isCompletedStatus = b.status == BookingStatus.completed;
          bool isExpiredConfirmed = (b.status == BookingStatus.confirmed && b.endDate.isBefore(now));
          return isCompletedStatus || isExpiredConfirmed;
        }).toList();

        final cancelledBookings = allBookings.where((b) => b.status == BookingStatus.cancelled).toList();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.grey[50],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(loc.myBooking, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: accentColor,
              centerTitle: true,
              bottom: TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: loc.waiting),
                  Tab(text: loc.confirmed),
                  Tab(text: loc.done),
                  Tab(text: loc.canceled),
                ],
              ),
            ),
            body: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildBookingList(pendingBookings, authProvider.token!, cardColor),
                      _buildBookingList(confirmedBookings, authProvider.token!, cardColor),
                      _buildBookingList(completedBookings, authProvider.token!, cardColor),
                      _buildBookingList(cancelledBookings, authProvider.token!, cardColor),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // بناء قائمة الحجوزات لكل تاب
  Widget _buildBookingList(List<Booking> bookings, String token,Color cardColor) {
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
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            loc.noBookingYet,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.startFirstBooking,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // بناء كارد الحجز
  Widget _buildBookingCard(Booking booking) {
    final loc = AppLocalizations.of(context)!;

    // استخدام Consumer للوصول إلى بيانات الشقق و AuthProvider للتوكن
    return Consumer2<ApartmentProvider, AuthProvider>(
      builder: (context, aptProv, authProv, child) {
        return FutureBuilder<Apartment?>(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment?.name ?? loc.loadingName,
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
                                          : loc.loadingLocation,
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
                        _buildStatusBadge(booking.status, context),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateItem(loc.from, booking.startDate),
                        _buildDateItem(loc.to, booking.endDate),
                        _buildPriceItem(booking.totalPrice),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        (() {
                          final isExpired = booking.endDate.isBefore(
                            DateTime.now(),
                          );
                          final isConfirmed =
                              booking.status == BookingStatus.confirmed;
                          final isCompleted =
                              booking.status == BookingStatus.completed;

                          if (isCompleted || (isConfirmed && isExpired)) {
                            return Expanded(
                              child: Row(
                                children: [
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
                                      label: Text(loc.reviews),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.amber[900],
                                        side: BorderSide(
                                          color: Colors.amber[700]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _rateApartment(booking),
                                      icon: const Icon(
                                        Icons.add_comment,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        loc.rateNow,
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
                                      label: Text(loc.cancel),
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
                                      label: Text(
                                        loc.edit,
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
                                child: Center(
                                  child: Text(
                                    loc.modificationUnderReview,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          if (booking.status == BookingStatus.cancelled) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  loc.bookingCanceled,
                                  style: const TextStyle(
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
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(loc.total, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          "${price.toStringAsFixed(0)} ل.س",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: accentColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status, BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Color color;
    String text;
    switch (status) {
      case BookingStatus.confirmed:
        color = Colors.green;
        text = loc.confirmed;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = loc.cancelled;
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        text = loc.completed;
        break;
      case BookingStatus.pendingUpdate:
        color = Colors.deepOrange;
        text = loc.pendingUpdate;
        break;
      case BookingStatus.pending:
      default:
        color = Colors.orange;
        text = loc.pending;
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
    final loc = AppLocalizations.of(context)!;
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.confirmCancelTitle),
            content: Text(loc.confirmCancelContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.no),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(loc.confirm, style: TextStyle(color: Colors.white)),
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
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.errorFetchingReviews}: $e')),
        );
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
        final loc = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                loc.apartmentRating, // استدعاء الترجمة بدل النص الثابت
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
                    "${data['average_rating']}", // يبقى من السيرفر
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
                '${loc.totalReviews}: ${data['total_reviews']}', // ترجمة + بيانات runtime
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: Text(
                  loc.close, // ترجمة زر الإغلاق
                  style: const TextStyle(color: Colors.white),
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
      final loc = AppLocalizations.of(context)!; // ✅ استدعاء loc هنا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.errorFetchingReviews}: $e',
          ), // ✅ النص مترجم مع البيانات runtime
        ),
      );
    }
  }
}
