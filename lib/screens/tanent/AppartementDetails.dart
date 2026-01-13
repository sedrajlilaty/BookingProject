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
  bool isFavoriteLocal = false;
  @override
  void initState() {
    super.initState();
    log(widget.apartment.images.first.image);
    _checkFavoriteStatus();
    isFavoriteLocal = widget.apartment.isFavorited;
    //widget.apartment.isFavorited = !widget.apartment.isFavorited;
  }

  void _toggleFavorite() async {
    setState(() {
      widget.apartment.isFavorited = !widget.apartment.isFavorited;
    });

    try {
      // هنا تستدعي الـ Provider الخاص بك لإرسال الطلب للسيرفر
      // await Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(widget.apartment.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.apartment.isFavorited
                ? "Added to Favorites"
                : "Removed from Favorites",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // إذا فشل الطلب، نعيد الحالة كما كانت
      setState(() {
        widget.apartment.isFavorited = !widget.apartment.isFavorited;
      });
    }
  }

  void _checkFavoriteStatus() async {
    final favoriteService = FavoriteService();
    bool status = await favoriteService.isFavorite(widget.apartment.id);
    if (mounted) {
      setState(() {
        isFavoriteLocal = status;
        widget.apartment.isFavorited = status; // مزامنة الموديل
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;

    //final images = apartment.images

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : Colors.brown.shade50;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.white;
        Color textColor = isDark ? Colors.white : Colors.black87;
        print(
          "UI DEBUG: Apartment ${widget.apartment.name} isFavorited = ${widget.apartment.isFavorited}",
        );
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            children: [
              // ================= IMAGES =================
              // داخل ApartmentDetailsPage في كود الـ Scaffold
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
                        final String imagePath = apartment.images[index].image;
                        return Image.network(
                          imagePath,

                          fit: BoxFit.cover,

                          width: double.infinity,
                          // مؤشر تحميل أثناء جلب الصورة من السيرفر
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          // في حال فشل الرابط (مثلاً 404 أو خطأ شبكة)
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // زر الرجوع (الموجود في كودك الأصلي)
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

                    // زر المفضلة (الموجود في كودك الأصلي)
                    Positioned(
                      top: 40,
                      right: 20,
                      child: InkWell(
                        // داخل InkWell -> onTap
                        onTap:
                            isLoading
                                ? null
                                : () async {
                                  setState(() => isLoading = true);

                                  final favoriteService = FavoriteService();
                                  bool success = await favoriteService
                                      .toggleFavorite(widget.apartment.id);

                                  if (!mounted)
                                    return; // 💡 السطر الأهم لمنع الخطأ الذي ظهر في الصورة

                                  if (success) {
                                    setState(() {
                                      isFavoriteLocal = !isFavoriteLocal;
                                      widget.apartment.isFavorited =
                                          isFavoriteLocal;
                                      isLoading = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFavoriteLocal
                                              ? "تمت الإضافة للمفضلة"
                                              : "تم الحذف من المفضلة",
                                        ),
                                        backgroundColor:
                                            isFavoriteLocal
                                                ? Colors.redAccent
                                                : Colors.grey,
                                      ),
                                    );
                                  } else {
                                    setState(() => isLoading = false);
                                  }
                                },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          // إضافة ظل خفيف للزر
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.redAccent,
                                      ),
                                    ),
                                  )
                                  : Icon(
                                    // الاعتماد على الحالة الموجودة في الموديل apartment.isFavorited
                                    apartment.isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        apartment.isFavorited
                                            ? Colors.red
                                            : Colors.grey[400],
                                    size: 26,
                                  ),
                        ),
                      ),
                    ),

                    // نقاط التنقل (Dots Indicator)
                    if (apartment.images.length > 1)
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
                        Text(
                          apartment.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        /*const SizedBox(height: 10),
                        Text(
                          'An amazing appartement in ${apartment.city}  with excellent details.',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),*/
                        const SizedBox(height: 10),
                        Text(
                          "Type: ${apartment.type}",

                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// الوصف
                        Text(
                          apartment.description,
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),

                        const SizedBox(height: 14),
                        Text(
                          "Details :",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// التفاصيل
                        _info(
                          Icons.meeting_room,
                          '${apartment.rooms} rooms',
                          textColor,
                        ),
                        _info(
                          Icons.bathtub,
                          '${apartment.bathrooms} bathrooms',
                          textColor,
                        ),
                        _info(Icons.map, apartment.location, textColor),
                        _info(
                          Icons.location_on,
                          '${apartment.governorate} - ${apartment.city}',
                          textColor,
                        ),

                        _info(
                          Icons.crop_square,
                          '${apartment.area} m2',
                          textColor,
                        ),
                        _info(
                          Icons.attach_money,
                          '${apartment.price} \$ / month',
                          textColor,
                        ),

                        /// التواريخ
                        _info(
                          Icons.calendar_today,
                          ' Date of adding: ${formatDate(apartment.createdAt)}',
                          textColor,
                        ),

                        Card(
                          color: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 5,
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
                                child: const Text(
                                  ' Book Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
  bool _isAlreadyFavorite = false;
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
