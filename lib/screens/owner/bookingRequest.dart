import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/appartementProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/providers/authoProvider.dart'; // تأكد من صحة اسم الملف لديك
// تأكد من وجود بروفايدر الشقق
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:flutter_application_8/models/apartment_model.dart';

class BookingRequest extends StatefulWidget {
  const BookingRequest({super.key});

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  @override
  void initState() {
    super.initState();
    // جلب طلبات الحجز الخاصة بالمؤجر عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        Provider.of<BookingProvider>(
          context,
          listen: false,
        ).fetchOwnerBookings(auth.token!);
      }
    });
  }

  // تابع التعامل مع القبول أو الرفض
  Future<void> handleAction(dynamic bookingId, String action) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    await bookingProvider.handleBookingAction(bookingId, action, auth.token!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'approve' ? 'تمت العملية بنجاح' : 'تم رفض الطلب',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: action == 'approve' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    // فلترة الطلبات: المعلقة (pending) وطلبات التعديل (pendingUpdate)
    final allRequests =
        bookingProvider.bookings
            .where(
              (b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.pendingUpdate,
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'طلبات الحجز والتعديل',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
        elevation: 4,
      ),
      body:
          bookingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : allRequests.isEmpty
              ? const Center(child: Text("لا توجد طلبات معلقة حالياً"))
              : RefreshIndicator(
                onRefresh: () async {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await bookingProvider.fetchOwnerBookings(auth.token!);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: allRequests.length,
                  itemBuilder: (context, index) {
                    return _buildRequestCard(allRequests[index]);
                  },
                ),
              ),
    );
  }

  Widget _buildRequestCard(Booking item) {
    bool isUpdateReq = item.status == BookingStatus.pendingUpdate;
    // استدعاء ApartmentProvider لاستخدام تابع fetchApartmentById
    final aptProvider = Provider.of<ApartmentProvider>(context, listen: false);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "رقم الطلب: #${item.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _statusBadge(isUpdateReq),
              ],
            ),

            if (isUpdateReq) _modificationAlert(),

            const Divider(height: 25),

            // --- هنا يتم جلب تفاصيل الشقة من السيرفر باستخدام التابع الخاص بك ---
            FutureBuilder<Apartment?>(
              future: aptProvider.fetchApartmentById(item.apartmentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final apartment = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "اسم الشقة: ${apartment.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "الموقع: ${apartment.governorate ?? 'غير محدد'}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  );
                }

                // حالة فشل الجلب: نعرض البيانات الأساسية من كائن الحجز
                return Text("الشقة: ${item.apartmentName ?? 'تحميل...'}");
              },
            ),

            const SizedBox(height: 10),
            Text(
              "التاريخ المطلوب: ${item.startDate.day}/${item.startDate.month} إلى ${item.endDate.day}/${item.endDate.month}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              "السعر الإجمالي: ${item.totalPrice} ريال",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 15),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => handleAction(item.id, 'approve'),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(isUpdateReq ? "قبول التعديل" : "قبول الحجز"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => handleAction(item.id, 'reject'),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(isUpdateReq ? "رفض التعديل" : "رفض الحجز"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isUpdate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isUpdate ? Colors.deepOrange : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isUpdate ? "طلب تعديل" : "حجز جديد",
        style: TextStyle(
          color: isUpdate ? Colors.deepOrange : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _modificationAlert() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_calendar, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Text(
            "المستأجر يطلب تعديل تاريخ الحجز",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
