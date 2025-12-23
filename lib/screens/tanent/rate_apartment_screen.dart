import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/booking_model.dart';

class RateApartmentScreen extends StatefulWidget {
  final Booking booking;
  final Function(double rating, String review) onRatingSubmitted;

  const RateApartmentScreen({
    Key? key,
    required this.booking,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RateApartmentScreen> createState() => _RateApartmentScreenState();
}

class _RateApartmentScreenState extends State<RateApartmentScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // نقاط التقييم
  final List<String> _ratingPoints = [
    'سيء جداً',
    'سيء',
    'متوسط',
    'جيد',
    'ممتاز',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الشقة'),
        backgroundColor: accentColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(widget.booking.startDate)} - ${_formatDate(widget.booking.endDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // التقييم بالنجوم
              const Center(
                child: Text(
                  'كيف تقيم تجربتك في هذه الشقة؟',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    // النجوم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 50,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rating > 0 ? _ratingPoints[_rating.round() - 1] : '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      '${_rating.toStringAsFixed(1)} / 5',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // مجالات التقييم
              const Text(
                'تقييم المجالات المختلفة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildRatingCategory('النظافة', Icons.cleaning_services),
              _buildRatingCategory('الموقع', Icons.location_on),
              _buildRatingCategory('الخدمات', Icons.wifi),
              _buildRatingCategory('التواصل مع المالك', Icons.person),

              const SizedBox(height: 30),

              // التعليق
              const Text(
                'تعليقك (اختياري)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'شاركنا بتجربتك... ما أعجبك؟ ما يمكن تحسينه؟',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: accentColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'التعليق طويل جداً (الحد الأقصى 500 حرف)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${_reviewController.text.length}/500',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color:
                      _reviewController.text.length > 500
                          ? Colors.red
                          : Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 30),

              // نصائح للتعليق
              Card(
                color: Colors.blue[50],
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نصائح للتعليق المفيد:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('• وصف حالة الشقة والنظافة'),
                      Text('• تقييم الموقع والخدمات القريبة'),
                      Text('• ذكر نقاط القوة والضعف'),
                      Text('• نصائح للمستأجرين المستقبليين'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // زر التقييم
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rating > 0 ? accentColor : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'تقييم الشقة',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              // ملاحظة
              Center(
                child: Text(
                  'تقييمك يساعد المستأجرين الآخرين على اتخاذ قرار أفضل',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCategory(String title, IconData icon) {
    double categoryRating = 3.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < categoryRating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
                onPressed: () {
                  // هنا يمكن حفظ تقييم كل فئة بشكل منفصل
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار تقييم بالنجوم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // محاكاة انتظار
      await Future.delayed(const Duration(seconds: 1));

      widget.onRatingSubmitted(_rating, _reviewController.text);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('شكراً لتقييمك! تم حفظ التقييم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
