import 'package:flutter/material.dart';
// ✅ تصحيح الاسم
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/screens/tanent/bookingDone.dart';
// ✅ تصحيح الاسم
import 'package:provider/provider.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';

class FullBookingPage extends StatefulWidget {
  final double pricePerDay;
  final String apartmentId;
  final String apartmentName;
  final String apartmentImage;
  final String apartmentLocation;

  const FullBookingPage({
    super.key,
    required this.pricePerDay,
    required this.apartmentId,
    required this.apartmentName,
    required this.apartmentImage,
    required this.apartmentLocation,
  });

  @override
  State<FullBookingPage> createState() => _FullBookingPageState();
}

class _FullBookingPageState extends State<FullBookingPage> {
  String selectedDuration = "أسبوع";
  String selectedPayment = "نقدًا";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  late double pricePerDay;
  double totalPrice = 0;
  int numberOfMonths = 1;

  final durationOptions = ["أسبوع", "شهر", "عدة أشهر", "15 يوم", "سنة"];
  final paymentMethods = ["نقدًا", "بطاقة ائتمان", "محفظة إلكترونية"];

  @override
  void initState() {
    super.initState();
    pricePerDay = widget.pricePerDay;
    calculateEndDate();
  }

  // دالة لحساب تاريخ الانتهاء والسعر الإجمالي
  void calculateEndDate() {
    switch (selectedDuration) {
      case "أسبوع":
        endDate = startDate.add(const Duration(days: 7));
        totalPrice = pricePerDay * 7;
        break;
      case "شهر":
        endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
        totalPrice = pricePerDay * 30;
        break;
      case "عدة أشهر":
        endDate = DateTime(
          startDate.year,
          startDate.month + numberOfMonths,
          startDate.day,
        );
        totalPrice = pricePerDay * 30 * numberOfMonths;
        break;
      case "15 يوم":
        endDate = startDate.add(const Duration(days: 15));
        totalPrice = pricePerDay * 15;
        break;
      case "سنة":
        endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
        totalPrice = pricePerDay * 365;
        break;
    }
    setState(() {});
  }

  // دالة لاختيار تاريخ البدء
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        calculateEndDate();
      });
    }
  }

  // دالة لتحديد عدد الأشهر عند اختيار "عدة أشهر"
  Future<void> selectNumberOfMonths(BuildContext context) async {
    final months = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("اختر عدد الأشهر"),
            content: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "عدد الأشهر",
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (val) {
                final parsedValue = int.tryParse(val) ?? 1;
                Navigator.of(context).pop(parsedValue);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(1),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value =
                      (context as Element)
                          .findAncestorWidgetOfExactType<TextFormField>()
                          ?.controller
                          ?.text;
                  Navigator.of(context).pop(int.tryParse(value ?? '') ?? 1);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
    );

    if (months != null && months > 0) {
      setState(() {
        numberOfMonths = months;
        calculateEndDate();
      });
    }
  }

  // دالة لإضافة الحجز
  void _addBooking(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authProvider.user!;
    final now = DateTime.now();
    final durationInDays = endDate.difference(startDate).inDays;

    // إنشاء ID فريد للحجز
    final String bookingId =
        'B${now.millisecondsSinceEpoch}${_getUserPrefix(user.id)}';

    // إنشاء كائن الحجز
    final Map<String, dynamic> newBooking = {
      'id': bookingId,
      'userId': user.id,
      'apartmentId': widget.apartmentId,
      'apartmentName': widget.apartmentName,
      'apartmentImage': widget.apartmentImage,
      'apartmentLocation': widget.apartmentLocation,
      'startDate': startDate,
      'endDate': endDate,
      'pricePerDay': pricePerDay,
      'totalPrice': totalPrice,
      'status': 'pending',
      'paymentMethod': selectedPayment,
      'bookingDate': now,
      'hasRated': false,
    };

    // إضافة الحجز إلى Provider
    bookingProvider.addBooking(newBooking);

    // الانتقال إلى شاشة تأكيد الحجز
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingDone(
              bookingId: bookingId,
              apartmentName: widget.apartmentName,
              apartmentLocation: widget.apartmentLocation,
              totalPrice: totalPrice,
              checkInDate: startDate,
              checkOutDate: endDate,
              paymentMethod: selectedPayment,
              durationInDays: durationInDays,
            ),
      ),
    );
  }

  // دالة مساعدة للحصول على بادئة المستخدم
  String _getUserPrefix(String userId) {
    if (userId.isEmpty) return 'USR';
    return userId.length > 3 ? userId.substring(0, 3) : userId;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: const Text(
          ' الحجز  ',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الشقة
              Card(
                color: cardBackgroundColor,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 90,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.apartmentName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),

                      Text(
                        'السعر اليومي: \$${pricePerDay.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // مدة الحجز
              const Text(
                "مدة الحجز",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDuration,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardBackgroundColor.withOpacity(0.17),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                items:
                    durationOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    if (value == "عدة أشهر") {
                      await selectNumberOfMonths(context);
                    }

                    setState(() {
                      selectedDuration = value;
                      calculateEndDate();
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // تاريخ البداية
              const Text(
                "تاريخ بداية الحجز",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => selectStartDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor.withOpacity(0.15),
                    border: Border.all(color: accentColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(startDate)),
                      Icon(Icons.calendar_today, color: accentColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // تاريخ النهاية
              const Text(
                "تاريخ نهاية الحجز",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: cardBackgroundColor.withOpacity(0.15),
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(endDate)),
                    Icon(Icons.event_available, color: accentColor),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // طريقة الدفع
              const Text(
                "طريقة الدفع",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedPayment,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardBackgroundColor.withOpacity(0.15),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                items:
                    paymentMethods
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPayment = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // ملخص السعر
              Card(
                color: cardBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "ملخص السعر",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        "السعر اليومي",
                        "\$${pricePerDay.toStringAsFixed(2)}",
                      ),
                      _buildPriceRow(
                        "عدد الأيام",
                        "${endDate.difference(startDate).inDays} يوم",
                      ),
                      const Divider(),
                      _buildPriceRow(
                        "الإجمالي",
                        "\$${totalPrice.toStringAsFixed(2)}",
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // زر تأكيد الحجز
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (authProvider.user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يجب تسجيل الدخول لإتمام الحجز'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          _addBooking(context);
                        }
                      },
                      child: Text(
                        authProvider.user == null
                            ? 'سجل الدخول للحجز'
                            : 'تأكيد الحجز',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // شروط وأحكام
              Card(
                color: cardBackgroundColor,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ملاحظات مهمة:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "• يمكن إلغاء الحجز خلال 24 ساعة من التأكيد\n"
                        "• السعر يشمل الضرائب والخدمات\n"
                        "• تأكد من تواريخ الحجز قبل التأكيد\n"
                        "• سيتواصل معك المالك لتأكيد التفاصيل",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // مسافة إضافية في الأسفل
            ],
          ),
        ),
      ),
    );
  }

  // Widget لبناء صف السعر
  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}
