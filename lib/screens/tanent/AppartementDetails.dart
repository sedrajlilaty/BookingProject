import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../constants.dart';
import 'favorateScreen.dart';
import 'fullbookingPage.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> apartment;

  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // التحقق إذا كانت الشقة موجودة في المفضلة
    isFavorite = FavoritesScreen.favoriteApartments.any(
          (apt) => apt['title'] == widget.apartment['title'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;
    final List<String> images = [
      'assets/images/apartment1_1.jpg',
      'assets/images/apartment1_2.jpg',
      'assets/images/apartment1_3.jpg',
    ];

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor = isDark ? Colors.grey[900]! : Colors.brown.shade50;
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
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          images[index],
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
                    // زر المفضلة
                    Positioned(
                      top: 40,
                      right: 20,
                      child: InkWell(
                        onTap: _toggleFavorite,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    // مؤشرات الصور
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
                              color: _currentPage == index
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apartment['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'شقة رائعة تقع في ${apartment['city']} بمواصفات ممتازة.',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 20),
                        _info(Icons.location_on, apartment['city'], textColor),
                        _info(Icons.crop_square, '${apartment['area']} متر مربع', textColor),
                        _info(Icons.attach_money, '${apartment['price']} \$ / شهر', textColor),
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
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullBookingPage(
                                        pricePerDay: apartment['price'].toDouble(),
                                        apartmentId: apartment['id'].toString(),
                                        apartmentName: apartment['name'].toString(),          // اسم الشقة
                                        apartmentImage: apartment['image'].toString(),        // رابط الصورة
                                        apartmentLocation: apartment['location'].toString(),  // الموقع
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
  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;

      if (isFavorite) {
        if (!FavoritesScreen.favoriteApartments.any(
              (apt) => apt['title'] == widget.apartment['title'],
        )) {
          final apartmentWithImages = Map<String, dynamic>.from(widget.apartment);
          apartmentWithImages['images'] = [
            'assets/images/apartment1_1.jpg',
            'assets/images/apartment1_2.jpg',
            'assets/images/apartment1_3.jpg',
          ];
          FavoritesScreen.favoriteApartments.add(apartmentWithImages);
        }
      } else {
        FavoritesScreen.favoriteApartments.removeWhere(
              (apt) => apt['title'] == widget.apartment['title'],
        );
      }
    });
  }

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
