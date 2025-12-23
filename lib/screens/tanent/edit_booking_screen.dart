import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:intl/intl.dart';

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
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedPayment;
  late int _numberOfDays;
  double _totalPrice = 0;

  final List<String> _paymentMethods = [
    'نقدًا',
    'بطاقة ائتمان',
    'محفظة إلكترونية',
    'تحويل بنكي',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.booking.startDate;
    _endDate = widget.booking.endDate;
    _selectedPayment = widget.booking.paymentMethod;
    _numberOfDays = widget.booking.durationInDays;
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    _totalPrice = widget.booking.pricePerDay * _numberOfDays;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _endDate = picked.add(Duration(days: _numberOfDays));
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _numberOfDays = _endDate.difference(_startDate).inDays;
        _calculateTotalPrice();
      });
    }
  }

  void _updateNumberOfDays(int days) {
    setState(() {
      _numberOfDays = days;
      _endDate = _startDate.add(Duration(days: days));
      _calculateTotalPrice();
    });
  }

  void _saveChanges() {
    final updatedBooking = widget.booking.copyWith(
      startDate: _startDate,
      endDate: _endDate,
      totalPrice: _totalPrice,
      paymentMethod: _selectedPayment,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الحجز'),
        backgroundColor: accentColor,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الشقة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.apartmentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.booking.apartmentLocation,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'السعر اليومي: \$${widget.booking.pricePerDay.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_startDate)),
                    Icon(Icons.calendar_today, color: accentColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // مدة الحجز
            const Text(
              'مدة الإقامة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDurationButton(7, 'أسبوع'),
                _buildDurationButton(15, '15 يوم'),
                _buildDurationButton(30, 'شهر'),
                _buildDurationButton(60, 'شهران'),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _numberOfDays > 1
                          ? () => _updateNumberOfDays(_numberOfDays - 1)
                          : null,
                ),
                Text(
                  '$_numberOfDays يوم',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateNumberOfDays(_numberOfDays + 1),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // تاريخ النهاية
            const Text(
              'تاريخ نهاية الحجز',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectEndDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_endDate)),
                    Icon(Icons.calendar_today, color: accentColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // طريقة الدفع
            const Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
              items:
                  _paymentMethods
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPayment = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            // ملخص التعديل
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'ملخص التعديل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'السعر اليومي',
                      '\$${widget.booking.pricePerDay.toStringAsFixed(2)}',
                    ),
                    _buildSummaryRow('عدد الأيام', '$_numberOfDays يوم'),
                    const Divider(),
                    _buildSummaryRow(
                      'الإجمالي الجديد',
                      '\$${_totalPrice.toStringAsFixed(2)}',
                    ),
                    _buildSummaryRow(
                      'الإجمالي السابق',
                      '\$${widget.booking.totalPrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    if (_totalPrice > widget.booking.totalPrice)
                      Text(
                        'زيادة: \$${(_totalPrice - widget.booking.totalPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (_totalPrice < widget.booking.totalPrice)
                      Text(
                        'توفير: \$${(widget.booking.totalPrice - _totalPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // أزرار الحفظ والإلغاء
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'حفظ التعديلات',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton(int days, String label) {
    return OutlinedButton(
      onPressed: () => _updateNumberOfDays(days),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: _numberOfDays == days ? accentColor : Colors.grey,
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
