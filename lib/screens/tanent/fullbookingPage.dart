import 'package:flutter/material.dart';

import 'package:flutter_application_8/l10n/app_localizations.dart';

import 'package:flutter_application_8/providers/authoProvider.dart';

import 'package:flutter_application_8/providers/booking_provider.dart';

import 'package:provider/provider.dart';

import 'package:flutter_application_8/constants.dart';

import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Theme/theme_cubit.dart';

import '../../Theme/theme_state.dart';

// Note: Ensure that the bookingDone.dart file contains the bool variable isPendingApproval

import 'package:flutter_application_8/screens/tanent/bookingDone.dart';

class FullBookingPage extends StatefulWidget {
  final double pricePerDay;

  final int apartmentId; // Modified to int to resolve type issue

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
  // في أعلى الكلاس
  String? selectedDuration;
  String? selectedPayment;

  @override
 void didChangeDependencies() {
  super.didChangeDependencies();
  final loc = AppLocalizations.of(context)!;
  if (selectedDuration == null) {
    selectedDuration = loc.week; // تعيين القيمة الابتدائية
    calculateEndDate(); // احسب السعر لأول مرة بناءً على القيمة الابتدائية
  }
  if (selectedPayment == null) {
    selectedPayment = loc.cash;
  }
}

  DateTime startDate = DateTime.now();

  DateTime endDate = DateTime.now().add(const Duration(days: 7));

  late double pricePerDay;

  double totalPrice = 0;

  int numberOfMonths = 1;

  @override
  void initState() {
    super.initState();

    pricePerDay = widget.pricePerDay;

 
  }
void calculateEndDate() {
  final loc = AppLocalizations.of(context);
  if (loc == null) return; // تأكد أن الترجمة جاهزة

  if (selectedDuration == loc.week) {
    endDate = startDate.add(const Duration(days: 7));
    totalPrice = pricePerDay * 7;
  } else if (selectedDuration == loc.month) {
    endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
    totalPrice = pricePerDay * 30;
  } else if (selectedDuration == loc.fifteenDays) {
    endDate = startDate.add(const Duration(days: 15));
    totalPrice = pricePerDay * 15;
  } else if (selectedDuration == loc.severalMonths) {
    endDate = DateTime(startDate.year, startDate.month + numberOfMonths, startDate.day);
    totalPrice = pricePerDay * 30 * numberOfMonths;
  } else if (selectedDuration == loc.year) {
    endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
    totalPrice = pricePerDay * 365;
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

  Future<void> selectNumberOfMonths(BuildContext context) async {
    final controller = TextEditingController(text: numberOfMonths.toString());

    final loc = AppLocalizations.of(context)!;

    final months = await showDialog<int>(
      context: context,

      builder:
          (context) => AlertDialog(
            title: const Text("Select Number of Months"),

            content: TextField(
              controller: controller,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                hintText: "Number of Months",

                border: OutlineInputBorder(),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),

                child: Text(loc.cancel),
              ),

              ElevatedButton(
                onPressed: () {
                  final value = int.tryParse(controller.text) ?? 1;

                  Navigator.pop(context, value);
                },

                child: Text(loc.confirmed),
              ),
            ],
          ),
    );

    if (months != null && months > 0) {
      setState(() {
        numberOfMonths = months;

        selectedDuration = loc.severalMonths;

        calculateEndDate();
      });
    }
  }

  // 1. Added async to the function to be able to use await

 Future<void> _addBooking(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

  if (authProvider.user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يجب تسجيل الدخول أولاً'), backgroundColor: Colors.red),
    );
    return;
  }

  // إظهار دائرة تحميل لمنع التضارب الناتج عن الضغط المتكرر
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // تجهيز البيانات بدقة (تأكد من مطابقة أسماء الحقول لما يتوقعه السيرفر)
    final Map<String, dynamic> newBooking = {
      "apartment_id": widget.apartmentId,
      "start_date": DateFormat('yyyy-MM-dd').format(startDate), // تنسيق ثابت
      "end_date": DateFormat('yyyy-MM-dd').format(endDate),     // تنسيق ثابت
    };

    bool success = await bookingProvider.createBookingOnServer(
      newBooking,
      authProvider.token!,
    );

    Navigator.pop(context); // إغلاق دائرة التحميل

    if (success) {
      // الانتقال لصفحة النجاح
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDone(
            bookingId: "B${DateTime.now().millisecondsSinceEpoch}",
            apartmentName: widget.apartmentName,
            apartmentLocation: widget.apartmentLocation,
            totalPrice: totalPrice,
            checkInDate: startDate,
            checkOutDate: endDate,
            paymentMethod: selectedPayment!,
            durationInDays: endDate.difference(startDate).inDays,
          ),
        ),
      );
    } else {
      // إذا كان الخطأ 409 (Conflict) سيظهر هذا التنبيه
      _showErrorSnackBar(context, 'عذراً، هذه التواريخ محجوزة بالفعل أو هناك تضارب في البيانات.');
    }
  } catch (e) {
    Navigator.pop(context); // إغلاق التحميل في حال حدوث خطأ تقني
    _showErrorSnackBar(context, 'حدث خطأ غير متوقع: $e');
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
  );
}

  String _getUserPrefix(String userId) {
    if (userId.isEmpty) return 'USR';
    return userId.length > 3 ? userId.substring(0, 3) : userId;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final durationOptions = [
      loc.week,
      loc.month,
      loc.severalMonths,
      loc.fifteenDays,
      loc.year,
    ];

    final paymentMethods = [loc.cash, loc.creditCard, loc.eWallet];

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
            title: Text(
              loc.booking,

              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),
            ),

            backgroundColor: accent,

            centerTitle: true,

            elevation: 4,

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
                  // Apartment information card
                  Card(
                    color: cardColor,

                    elevation: 3,

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,

                        horizontal: 20,
                      ),

                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              widget.apartmentName,

                              style: TextStyle(
                                fontSize: 24,

                                fontWeight: FontWeight.bold,

                                color: accent,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '${loc.dailyPrice}: \$${pricePerDay.toStringAsFixed(2)}',

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

                  _buildLabel(loc.bookingDuration),

                  _buildDropdown(
                    durationOptions,

                    selectedDuration!,

                    (String? newValue) async {
                      if (newValue == loc.severalMonths) {
                        await selectNumberOfMonths(context);
                      }

                      setState(() {
                        selectedDuration = newValue!;

                        calculateEndDate();
                      });
                    },

                    cardColor,

                    textColor,

                    accent,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel(loc.bookingStartDate),

                  _buildDateTile(
                    dateFormat.format(startDate),

                    Icons.calendar_today,

                    () => selectStartDate(context),

                    cardColor,

                    textColor,

                    accent,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel(loc.bookingEndDate),

                  _buildDateTile(
                    dateFormat.format(endDate),

                    Icons.event_available,

                    null,

                    cardColor,

                    textColor,

                    accent,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel(loc.paymentMethod),

                  _buildDropdown(
                    paymentMethods,

                    selectedPayment!,

                    (String? newValue) {
                      setState(() => selectedPayment = newValue!);
                    },

                    cardColor,

                    textColor,

                    accent,
                  ),

                  const SizedBox(height: 25),

                  // Price summary
                  Card(
                    color: cardColor,

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Text(
                            loc.orderSummary,

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: accent,
                            ),
                          ),

                          const Divider(),

                          _buildPriceRow(
                            loc.stayDuration,

// استبدل السطر القديم بهذا السطر:
"${endDate.difference(startDate).inDays} ${loc.day}",
                            textColor,
                          ),

                          _buildPriceRow(
                            loc.total,

                            "\$${totalPrice.toStringAsFixed(2)}",

                            accent,

                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pending approval notice
                  Container(
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),

                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            loc.bookingApprovalNote,

                            style: TextStyle(
                              fontSize: 12,

                              color:
                                  isDark
                                      ? Colors.orange[200]
                                      : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () => _addBooking(context),

                      child:  Text(
                        loc.sendBookingRequest,

                        style: TextStyle(fontSize: 18, color: Colors.white),
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

  // Helper widgets to reduce code duplication

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),

    child: Text(
      text,

      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _buildDropdown(
    List<String> items,

    String value,

    Function(String?) onChanged,

    Color cardColor,

    Color textColor,

    Color accent,
  ) {
    return DropdownButtonFormField<String>(
      value: value,

      dropdownColor: cardColor,

      decoration: InputDecoration(
        filled: true,

        fillColor: cardColor.withOpacity(0.15),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent),

          borderRadius: BorderRadius.circular(8),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),

          borderRadius: BorderRadius.circular(8),
        ),
      ),

      style: TextStyle(color: textColor),

      items:
          items.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),

      onChanged: onChanged,
    );
  }

  Widget _buildDateTile(
    String text,

    IconData icon,

    VoidCallback? onTap,

    Color cardColor,

    Color textColor,

    Color accent,
  ) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),

        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.15),

          border: Border.all(color: accent, width: 1.5),

          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(text, style: TextStyle(color: textColor)),

            Icon(icon, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,

    String value,

    Color color, {

    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14)),

          Text(
            value,

            style: TextStyle(
              fontSize: isTotal ? 18 : 14,

              fontWeight: FontWeight.bold,

              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
