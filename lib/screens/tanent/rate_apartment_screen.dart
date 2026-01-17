import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_application_8/models/booking_model.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

class RateApartmentScreen extends StatefulWidget {
  final Booking booking;
  final Function(double rating, String review) onRatingSubmitted;

  const RateApartmentScreen({
    super.key,
    required this.booking,
    required this.onRatingSubmitted,
  });

  @override
  State<RateApartmentScreen> createState() => _RateApartmentScreenState();
}

class _RateApartmentScreenState extends State<RateApartmentScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  
  
  void _submitRating() async {
    
    if (_rating == 0) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      try {
        // 1. إرسال التقييم للسيرفر
        await bookingProvider.submitReview(
          bookingId: widget.booking.id,
          rating: _rating,
          comment: _reviewController.text,
          token: authProvider.token!,
        );

        // 2. تحديث قائمة الحجوزات فوراً لكي يتغير الزر في الخلفية
        await bookingProvider.fetchUserBookings(authProvider.token!);

        if (!mounted) return;

        // 3. عرض رسالة النجاح *قبل* إغلاق الشاشة لضمان وجود سياق (Context) صالح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            
            content: Text('تم حفظ التقييم بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // 4. الآن نغلق الشاشة ونعود للقائمة المحدثة
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // في حالة الخطأ، نعرض الرسالة دون إغلاق الشاشة لكي يعرف المستخدم ما حدث
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final loc = AppLocalizations.of(context)!;
      final List<String> _ratingPoints = [
    
    loc.veryBad,
   loc.bad,
    loc.average,
    loc.good,
   loc.excellent,
  ];
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
              title:  Text(
                loc.rateApartment,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: accentColor,
              centerTitle: true,
              elevation: 4,
              automaticallyImplyLeading: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
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
                       loc.rateExperience,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
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
                                  index < _rating.round()
                                      ? Icons.star
                                      : Icons.star_border,
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
                            _rating > 0
                                ? _ratingPoints[_rating.round() - 1]
                                : '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: starColor,
                            ),
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
                          backgroundColor:
                              _rating > 0 ? accentColor : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                :  Text(
                                  loc.rateApartment,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                       loc.ratingHelps,
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
