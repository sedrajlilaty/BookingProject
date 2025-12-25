import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

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

  final List<String> _ratingPoints = [
    'سيء جداً',
    'سيء',
    'متوسط',
    'جيد',
    'ممتاز',
  ];

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
      await Future.delayed(const Duration(seconds: 1));
      widget.onRatingSubmitted(_rating, _reviewController.text);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('شكراً لتقييمك! تم حفظ التقييم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is DarkState;
        final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        final cardColor = isDark ? Colors.grey[850]! : Colors.white;
        final starColor = Colors.amber;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text(
                'تقييم الشقة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: accentColor,
              centerTitle: true,
              elevation: 4,
              automaticallyImplyLeading: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 170),

                    Center(
                      child: Text(
                        'كيف تقيم تجربتك في هذه الشقة؟',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating.round() ? Icons.star : Icons.star_border,
                                  color: starColor,
                                  size: 50,
                                ),
                                onPressed: () {
                                  setState(() => _rating = index + 1.0);
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rating > 0 ? _ratingPoints[_rating.round() - 1] : '',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: starColor),
                          ),
                          Text(
                            '${_rating.toStringAsFixed(1)} / 5',
                            style: TextStyle(fontSize: 14, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _rating > 0 ? accentColor : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('تقييم الشقة', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'تقييمك يساعد المستأجرين الآخرين على اتخاذ قرار أفضل',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
