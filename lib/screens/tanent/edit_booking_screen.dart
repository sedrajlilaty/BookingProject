import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:flutter_application_8/providers/appartementProvider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // أضف هذا لاستخدام البروفايدر
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../providers/booking_provider.dart'; // تأكد من المسار
import '../../providers/authoProvider.dart'; // تأكد من المسار

class EditBookingScreen extends StatefulWidget {
  final Booking booking;
  final Function(Booking) onBookingUpdated;

  const EditBookingScreen({
    super.key,
    required this.booking,
    required this.onBookingUpdated,
  });

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late DateTime startDate;
  late DateTime endDate;
  late String selectedPayment;
  late double totalPrice;
  bool _isSaving = false; // لحالة التحميل عند الحفظ
  Apartment? apartmentDetails;
  bool _isLoadingDetails = true;
  @override
  void initState() {
    super.initState();
    startDate = widget.booking.startDate;
    endDate = widget.booking.endDate;
    selectedPayment = widget.booking.paymentMethod;
    _calculateTotal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchApartmentDetails();
    });
  }

  Future<void> _fetchApartmentDetails() async {
    try {
      final aptProv = Provider.of<ApartmentProvider>(context, listen: false);
      final details = await aptProv.fetchApartmentById(
        widget.booking.apartmentId,
      );
      if (mounted) {
        setState(() {
          apartmentDetails = details;
          _isLoadingDetails = false;
          _calculateTotal(); // إعادة الحساب بناءً على السعر المجلوب إن وجد
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  void _calculateTotal() {
    // حساب الفرق الفعلي بالأيام، وإذا كان أقل من يوم يحسب كـ 1
    int days = endDate.difference(startDate).inDays;
    if (days <= 0) days = 1;
    setState(() {
      double pricePerDay =
          apartmentDetails?.price ?? widget.booking.pricePerDay;
      totalPrice = pricePerDay * days;
    });
  }

  // دالة موحدة لاختيار التاريخ (بداية أو نهاية)
  Future<void> _selectDate(
    BuildContext context,
    bool isStart,
    Color accent,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate:
          isStart ? DateTime.now() : startDate.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: ColorScheme.light(primary: accent)),
            child: child!,
          ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // إذا أصبح تاريخ البدء بعد النهاية، يتم تعديل النهاية تلقائياً
          if (startDate.isAfter(endDate) ||
              startDate.isAtSameMomentAs(endDate)) {
            endDate = startDate.add(const Duration(days: 1));
          }
        } else {
          endDate = picked;
        }
        _calculateTotal();
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    // تجهيز البيانات
    // في صفحة EditBookingScreen
    final Map<String, dynamic> updateData = {
      "status": "pending_update", // إرسال الحالة أولاً
      "start_date": DateFormat(
        'yyyy-MM-dd',
      ).format(startDate), // التاريخ المقترح
      "end_date": DateFormat('yyyy-MM-dd').format(endDate),
    };
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final bookingProv = Provider.of<BookingProvider>(context, listen: false);

      bool success = await bookingProv.updateBooking(
        widget.booking.id,
        updateData,
        auth.token!,
      );

      if (success) {
        // تحديث الكائن المحلي مع وضع حالة الانتظار
        final updatedBooking = widget.booking.copyWith(
          startDate: startDate,
          endDate: endDate,
          totalPrice: totalPrice,
          paymentMethod: selectedPayment,
          status: BookingStatus.pendingUpdate,
        );

        widget.onBookingUpdated(updatedBooking);

        if (mounted) {
          Navigator.pop(context);
          // إظهار رسالة تفيد بأن التعديل يحتاج لموافقة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إرسال طلب التعديل بنجاح، بانتظار موافقة المؤجر',
              ),
              backgroundColor: Colors.orange, // لون تنبيهي للانتظار
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception("فشل التحديث");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالسيرفر'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            title: Text(
              "Editing Page",
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // كارد معلومات الشقة الثابتة
                _buildApartmentInfo(cardColor, accent),

                const SizedBox(height: 25),

                // حقل تاريخ البداية (قابل للتعديل)
                _buildLabel("تاريخ بداية الحجز"),
                _buildDateSelector(
                  date: startDate,
                  format: dateFormat,
                  color: cardColor,
                  accent: accent,
                  textColor: textColor,
                  onTap: () => _selectDate(context, true, accent),
                ),

                const SizedBox(height: 20),

                // حقل تاريخ النهاية (أصبح الآن قابلاً للتعديل)
                _buildLabel("تاريخ نهاية الحجز"),
                _buildDateSelector(
                  date: endDate,
                  format: dateFormat,
                  color: cardColor,
                  accent: accent,
                  textColor: textColor,
                  onTap: () => _selectDate(context, false, accent),
                ),

                const SizedBox(height: 20),

                _buildLabel("طريقة الدفع"),
                DropdownButtonFormField<String>(
                  value:
                      selectedPayment, // ملاحظة: استخدم value وليس initialValue
                  decoration: _inputDecoration(cardColor, accent),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('نقدًا')),
                    DropdownMenuItem(
                      value: 'credit_card',
                      child: Text('بطاقة ائتمان'),
                    ),
                    DropdownMenuItem(
                      value: 'wallet',
                      child: Text('محفظة إلكترونية'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedPayment = value);
                  },
                ),

                const SizedBox(height: 30),

                // ملخص السعر المحدث تلقائياً
                _buildPriceSummary(cardColor, textColor, accent),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(backgroundColor: accent),
                    child:
                        _isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'حفظ التعديلات وإرسال للسيرفر',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widgets مساعدة لتقليل تكرار الكود ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _buildDateSelector({
    required DateTime date,
    required DateFormat format,
    required Color color,
    required Color accent,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(format.format(date), style: TextStyle(color: textColor)),
            Icon(Icons.calendar_month, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _buildApartmentInfo(Color cardColor, Color accent) {
    if (_isLoadingDetails) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(color: accent),
        ),
      );
    }

    return Card(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // اسم الشقة المجلوب
            Text(
              apartmentDetails?.name ?? widget.booking.apartmentName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // عرض الموقع إذا توفر
            if (apartmentDetails != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${apartmentDetails!.city}, ${apartmentDetails!.governorate}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  "سعر الليلة",
                  "\$${apartmentDetails?.price ?? widget.booking.pricePerDay}",
                ),
                _buildInfoColumn(
                  "المساحة",
                  "${apartmentDetails?.area ?? '—'} م²",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(Color cardColor, Color textColor, Color accent) {
    int nights = endDate.difference(startDate).inDays;
    if (nights <= 0) nights = 1;

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'ملخص الحساب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildRow(
              'سعر الليلة',
              '\$${apartmentDetails?.price ?? widget.booking.pricePerDay}',
              textColor: textColor,
            ),
            _buildRow('عدد الليالي', '$nights ليلة', textColor: textColor),
            const Divider(),
            _buildRow(
              'الإجمالي الجديد',
              '\$${totalPrice.toStringAsFixed(2)}',
              isTotal: true,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(Color cardColor, Color accent) =>
      InputDecoration(
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
      );

  Widget _buildRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? accent,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: isTotal ? 16 : 14, color: textColor),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? accent : textColor,
            ),
          ),
        ],
      ),
    );
  }
}
