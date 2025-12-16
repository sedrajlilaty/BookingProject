import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:intl/intl.dart';

class FullBookingPage extends StatefulWidget {
  final double pricePerDay; // سعر الشقة اليومي

  const FullBookingPage({super.key, required this.pricePerDay});

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

  final durationOptions = [
    "أسبوع",
    "شهر",
    "عدة أشهر",
    "15 يوم",
    "سنة",
  ];

  final paymentMethods = [
    "نقدًا",
    "بطاقة ائتمان",
    "محفظة إلكترونية",
  ];

  @override
  void initState() {
    super.initState();
    pricePerDay = widget.pricePerDay; // تعيين السعر
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
        endDate = DateTime(startDate.year, startDate.month + numberOfMonths, startDate.day);
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
    setState(() {}); // لتحديث واجهة المستخدم
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "تفاصيل الحجز",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: accentColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                items: durationOptions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    if (value == "عدة أشهر") {
                      int? months = await showDialog<int>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("اختر عدد الأشهر"),
                          content: TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration:
                            const InputDecoration(hintText: "عدد الأشهر"),
                            onFieldSubmitted: (val) {
                              Navigator.of(context).pop(int.tryParse(val));
                            },
                          ),
                        ),
                      );

                      numberOfMonths = (months ?? 1);
                    }

                    setState(() {
                      selectedDuration = value;
                      calculateEndDate();
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // تاريخ الحجز
              const Text("تاريخ الحجز",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => selectStartDate(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor.withOpacity(0.15),
                    border: Border.all(color: accentColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(startDate)),
                ),
              ),

              const SizedBox(height: 20),

              // مدة الانتهاء
              const Text("مدة الانتهاء",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: cardBackgroundColor.withOpacity(0.15),
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(endDate)),
              ),

              const SizedBox(height: 20),

              // طريقة الدفع
              const Text("طريقة الدفع",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                items: paymentMethods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPayment = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // السعر الإجمالي
              const Text("السعر الإجمالي",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: cardBackgroundColor.withOpacity(0.15),
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$totalPrice \$",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // زر تأكيد الحجز
              SizedBox(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تأكيد الحجز!")),
                    );
                  },
                  child: const Text("تأكيد الحجز",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
