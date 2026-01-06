import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_8/services/favorateSErves.dart';
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
  bool isFavorite = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    log(widget.apartment.images.first.image);
    // التحقق إذا كانت الشقة موجودة في المفضلة
    /* isFavorite = FavoritesScreen.favoriteApartments.any(
      (apt) => apt['name'] == widget.apartment.name,
    );*/
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;
    final List<String> images = [
      'assets/images/apartment1_1.jpg',
      'assets/images/apartment1_2.jpg',
      'assets/images/apartment1_3.jpg',
    ];
    //final images = apartment.images

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : Colors.brown.shade50;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.white;
        Color textColor = isDark ? Colors.white : Colors.black87;

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
                    // زر الرجوع
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
                    Positioned(
                      top: 40,
                      right: 20,
                      child: InkWell(
                        onTap:
                            isLoading
                                ? null
                                : () async {
                                  // 1. استدعاء خدمة السيرفر
                                  final favoriteService = FavoriteService();

                                  setState(() {
                                    isLoading =
                                        true; // تفعيل مؤشر التحميل لمنع الضغط المتكرر
                                  });

                                  // 2. إرسال طلب (Toggle) للسيرفر (إضافة أو حذف بناءً على الحالة الحالية)
                                  bool success = await favoriteService
                                      .toggleFavorite(apartment.id);

                                  if (success) {
                                    setState(() {
                                      // 3. تحديث حالة القلب في الواجهة فقط عند نجاح طلب السيرفر
                                      isFavorite = !isFavorite;

                                      /* ملاحظة: تم حذف التعامل مع القائمة المحلية FavoritesScreen.favoriteApartments 
                لأن الكود الخاص بك الآن يجلب البيانات مباشرة من السيرفر عبر FutureBuilder 
                في صفحة المفضلة، مما يمنع تعارض البيانات ويحل مشكلة الـ Error.
                */
                                    });

                                    // رسالة تأكيد للمستخدم بناءً على الحالة الجديدة
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFavorite
                                              ? "تمت الإضافة للمفضلة"
                                              : "تمت الإزالة من المفضلة",
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    // في حال فشل الاتصال بالسيرفر أو انتهاء صلاحية التوكن
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "عذراً، تعذر تحديث المفضلة.. تأكد من الاتصال",
                                        ),
                                      ),
                                    );
                                  }

                                  setState(() {
                                    isLoading = false; // إيقاف مؤشر التحميل
                                  });
                                },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: accentColor,
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
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
                        Text(
                          apartment.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'شقة رائعة تقع في ${apartment.city} بمواصفات ممتازة.',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          apartment.type,
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// الوصف
                        Text(
                          apartment.description,
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),

                        const SizedBox(height: 24),

                        const SizedBox(height: 20),

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
                        _info(Icons.map, apartment.location, textColor),
                        _info(
                          Icons.location_city,
                          '${apartment.governorate} - ${apartment.city}',
                          textColor,
                        ),

                        _info(Icons.location_on, apartment.city, textColor),
                        _info(
                          Icons.crop_square,
                          '${apartment.area} متر مربع',
                          textColor,
                        ),
                        _info(
                          Icons.attach_money,
                          '${apartment.price} \$ / شهر',
                          textColor,
                        ),
                        const SizedBox(height: 30),
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

                        const SizedBox(height: 30),
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
                                onPressed: () async {
                                  // إظهار نافذة اختيار التاريخ أو الانتقال لصفحة الحجز الكاملة
                                  // بعد أن يختار المستخدم التواريخ في صفحة FullBookingPage، يتم تنفيذ الطلب:

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => FullBookingPage(
                                            pricePerDay:
                                                apartment.price.toDouble(),
                                            apartmentId:
                                                apartment
                                                    .id, // نمرر الـ ID كرقم
                                            apartmentName: apartment.name,
                                            apartmentImage:
                                                apartment.images.isNotEmpty
                                                    ? apartment.images[0].image
                                                    : '',
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
      }, // ← يغلق builder
    ); // ← يغلق BlocBuilder
  }

  // ================= FAVORITE =================
  // void _toggleFavorite() {
  //   setState(() {
  //     isFavorite = !isFavorite;

  //     if (isFavorite) {
  //       if (!FavoritesScreen.favoriteApartments.any(
  //             (apt) => apt['title'] == widget.apartment['title'],
  //       )) {
  //         final apartmentWithImages = Map<String, dynamic>.from(widget.apartment);
  //         apartmentWithImages['images'] = [
  //           'assets/images/apartment1_1.jpg',
  //           'assets/images/apartment1_2.jpg',
  //           'assets/images/apartment1_3.jpg',
  //         ];
  //         FavoritesScreen.favoriteApartments.add(apartmentWithImages);
  //       }
  //     } else {
  //       FavoritesScreen.favoriteApartments.removeWhere(
  //             (apt) => apt['title'] == widget.apartment['title'],
  //       );
  //     }
  //   });
  // }

  // ================= INFO ROW =================
  Widget _info(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: textColor)),
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
