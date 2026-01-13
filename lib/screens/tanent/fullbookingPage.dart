import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/screens/tanent/bookingDone.dart';
import 'package:flutter_application_8/services/Booking_Services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

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
  bool isBookingLoading = false;
  final durationOptions = ["أسبوع", "شهر", "عدة أشهر", "15 يوم", "سنة"];
  final paymentMethods = ["نقدًا", "بطاقة ائتمان", "محفظة إلكترونية"];

  @override
  void initState() {
    super.initState();
    pricePerDay = widget.pricePerDay;
    calculateEndDate();
  }

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

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final accent = accentColor;
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: accent)),
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

  Future<void> selectNumberOfMonths(BuildContext context) async {
    final controller = TextEditingController(text: numberOfMonths.toString());

    final months = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("اختر عدد الأشهر"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "عدد الأشهر",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = int.tryParse(controller.text) ?? 1;
                  Navigator.pop(context, value);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
    );

    if (months != null && months > 0) {
      setState(() {
        numberOfMonths = months;
        selectedDuration = "عدة أشهر";
        calculateEndDate();
      });
    }
  }

  void _addBooking(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // التحقق من تسجيل الدخول

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() => isBookingLoading = true); // تفعيل مؤشر التحميل

    try {
      final dateFormat = DateFormat('yyyy-MM-dd');

      // استدعاء خدمة الحجز (تأكد من إنشاء كلاس BookingService كما في الخطوة التالية)

      final response = await BookingService.addBooking(
        context,

        apartmentId: widget.apartmentId,

        startDate: dateFormat.format(startDate),

        endDate: dateFormat.format(endDate),
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        // إذا نجح الحجز في قاعدة البيانات

        final now = DateTime.now();

        final durationInDays = endDate.difference(startDate).inDays;

        final String bookingId = 'B${now.millisecondsSinceEpoch}';

        // الانتقال لصفحة نجاح الحجز

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحجز: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isBookingLoading = false); // إيقاف مؤشر التحميل
    }
  }

  String _getUserPrefix(String userId) {
    if (userId.isEmpty) return 'USR';
    return userId.length > 3 ? userId.substring(0, 3) : userId;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color accent = accentColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'الحجز',
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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: cardColor,
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
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                          Text(
                            'السعر اليومي: \$${pricePerDay.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "مدة الحجز",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDuration,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cardColor.withOpacity(0.17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    items:
                        durationOptions.map((d) {
                          return DropdownMenuItem<String>(
                            value: d,
                            child: Text(
                              d == "عدة أشهر"
                                  ? "عدة أشهر ($numberOfMonths)"
                                  : d,
                            ),
                          );
                        }).toList(),

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
                        color: cardColor.withOpacity(0.15),
                        border: Border.all(color: accent, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(startDate),
                            style: TextStyle(color: textColor),
                          ),
                          Icon(Icons.calendar_today, color: accent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      color: cardColor.withOpacity(0.15),
                      border: Border.all(color: accent, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(endDate),
                          style: TextStyle(color: textColor),
                        ),
                        Icon(Icons.event_available, color: accent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "طريقة الدفع",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPayment,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cardColor.withOpacity(0.15),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    items:
                        paymentMethods
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPayment = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "ملخص السعر",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            "السعر اليومي",
                            "\$${pricePerDay.toStringAsFixed(2)}",
                            textColor: textColor,
                          ),
                          _buildPriceRow(
                            "عدد الأيام",
                            "${endDate.difference(startDate).inDays} يوم",
                            textColor: textColor,
                          ),
                          const Divider(),
                          _buildPriceRow(
                            "الإجمالي",
                            "\$${totalPrice.toStringAsFixed(2)}",
                            isTotal: true,
                            textColor: accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width:
                                  double
                                      .infinity, // لضمان أخذ العرض بالكامل كما في التصميم
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      accentColor, // استخدام اللون المخصص في تطبيقك
                                  foregroundColor: Colors.white, // لون النص
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                // نتحقق من حالتين:
                                // 1. إذا كان التطبيق يحجز فعلاً (Loading) نعطل الزر.
                                // 2. إذا لم يكن هناك مستخدم مسجل، نعطل الضغط المباشر ونظهر رسالة.
                                onPressed:
                                    isBookingLoading
                                        ? null
                                        : () {
                                          if (authProvider.user == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'يجب تسجيل الدخول لإتمام الحجز',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            _addBooking(
                                              context,
                                            ); // استدعاء الدالة التي تتصل بالسيرفر
                                          }
                                        },
                                child:
                                    isBookingLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          // النص يتغير بناءً على حالة تسجيل الدخول
                                          authProvider.user == null
                                              ? 'سجل الدخول للحجز'
                                              : 'تأكيد الحجز',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: cardColor,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 90,
                      ),
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: textColor ?? (isTotal ? accentColor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
