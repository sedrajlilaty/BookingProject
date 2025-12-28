import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../constants.dart';
import '../../models/my_appartment_model.dart';
import 'fullbookingPage.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final ApartmentModel apartment;

  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : Colors.brown.shade50;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.white;
        Color textColor = isDark ? Colors.white : Colors.black87;
        Color subTextColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            children: [
              // ================= IMAGES =================
              SizedBox(
                height: 350,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: apartment.images.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          apartment.images[index].image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),

                    /// زر الرجوع
                    Positioned(
                      top: 40,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    /// مؤشرات الصور
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          apartment.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 10 : 8,
                            height: _currentPage == index ? 10 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _currentPage == index
                                      ? Colors.white
                                      : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= DETAILS =================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// اسم الشقة
                        Text(
                          apartment.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// النوع
                        Text(
                          apartment.type,
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),

                        const SizedBox(height: 16),

                        /// الوصف
                        Text(
                          apartment.description,
                          style: TextStyle(color: subTextColor),
                        ),

                        const SizedBox(height: 24),

                        /// الموقع
                        _info(Icons.map, apartment.location, textColor),
                        _info(
                          Icons.location_city,
                          '${apartment.governorate} - ${apartment.city}',
                          textColor,
                        ),

                        /// التفاصيل
                        _info(
                          Icons.meeting_room,
                          '${apartment.rooms} غرف',
                          textColor,
                        ),
                        _info(
                          Icons.bathtub,
                          '${apartment.bathrooms} حمامات',
                          textColor,
                        ),
                        _info(
                          Icons.crop_square,
                          '${apartment.area} م²',
                          textColor,
                        ),
                        _info(
                          Icons.attach_money,
                          '${apartment.price} \$ / شهر',
                          textColor,
                        ),

                        const SizedBox(height: 24),

                        /// التواريخ
                        _info(
                          Icons.calendar_today,
                          'تاريخ الإضافة: ${formatDate(apartment.createdAt)}',
                          textColor,
                        ),
                        _info(
                          Icons.update,
                          'آخر تعديل: ${formatDate(apartment.updatedAt)}',
                          textColor,
                        ),

                        const SizedBox(height: 32),

                        /// زر الحجز
                        Card(
                          color: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => FullBookingPage(
                                            pricePerDay:
                                                apartment.price.toDouble(),
                                            apartmentId:
                                                apartment.id.toString(),
                                            apartmentName: apartment.name,
                                            apartmentImage:
                                                apartment.images.first.image,
                                            apartmentLocation:
                                                apartment.location,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text('حجز الآن'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ========== INFO ROW ==========
  Widget _info(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}

String formatDate(String dateString) {
  try {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy/MM/dd – HH:mm').format(dateTime);
  } catch (e) {
    return dateString; // fallback إذا صار خطأ
  }
}
