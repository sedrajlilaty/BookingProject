import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking;
  final Function(Booking) onBookingUpdated;

  const EditBookingScreen({
    Key? key,
    required this.booking,
    required this.onBookingUpdated,
  }) : super(key: key);

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late DateTime startDate;
  late DateTime endDate;
  late String selectedPayment;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    startDate = widget.booking.startDate;
    endDate = widget.booking.endDate;
    selectedPayment = widget.booking.paymentMethod;
    _calculateTotal();
  }

  void _calculateTotal() {
    final days = endDate.difference(startDate).inDays;
    totalPrice = widget.booking.pricePerDay * days;
  }

  Future<void> _selectStartDate(BuildContext context, Color accent) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: accent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        endDate = picked.add(Duration(days: widget.booking.durationInDays));
        _calculateTotal();
      });
    }
  }

  void _saveChanges() {
    final updatedBooking = widget.booking.copyWith(
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      paymentMethod: selectedPayment,
    );

    widget.onBookingUpdated(updatedBooking);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث الحجز بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        // الألوان حسب الثيم
        Color backgroundColor = isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color accent = accentColor;

        return Theme(
          data: ThemeData(
            primaryColor: accent,
            scaffoldBackgroundColor: backgroundColor,
            cardColor: cardColor,
            textTheme: TextTheme(bodyMedium: TextStyle(color: textColor)),
            appBarTheme: AppBarTheme(
              backgroundColor: accent,
              elevation: 4,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: cardColor.withOpacity(0.15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accent, width: 2),
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('تعديل الحجز'),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات الشقة
                  Card(
                    color: cardColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 120,
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.booking.apartmentName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'السعر اليومي: \$${widget.booking.pricePerDay.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // تاريخ البداية
                  const Text(
                    'تاريخ بداية الحجز',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectStartDate(context, accent),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        border: Border.all(color: accent, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateFormat.format(startDate),
                              style: TextStyle(color: textColor)),
                          Icon(Icons.calendar_today, color: accent),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // تاريخ النهاية
                  const Text(
                    'تاريخ نهاية الحجز',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.15),
                      border: Border.all(color: accent, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateFormat.format(endDate),
                            style: TextStyle(color: textColor)),
                        Icon(Icons.event_available, color: accent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // طريقة الدفع
                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedPayment,
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
                    items: const [
                      DropdownMenuItem(value: 'نقدًا', child: Text('نقدًا')),
                      DropdownMenuItem(
                          value: 'بطاقة ائتمان', child: Text('بطاقة ائتمان')),
                      DropdownMenuItem(
                          value: 'محفظة إلكترونية',
                          child: Text('محفظة إلكترونية')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPayment = value);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ملخص السعر
                  Card(
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'ملخص السعر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRow('عدد الأيام',
                              '${endDate.difference(startDate).inDays} يوم', textColor: textColor),
                          const Divider(),
                          _buildRow(
                              'الإجمالي', '\$${totalPrice.toStringAsFixed(2)}',
                              isTotal: true, accent: accent),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // زر حفظ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text(
                        'تحديث الحجز',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value,
      {bool isTotal = false, Color? accent, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                color: textColor ?? Colors.grey[600],
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? accent ?? accentColor : textColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
