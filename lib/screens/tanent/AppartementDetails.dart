import 'package:flutter/material.dart';
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
    // التحقق إذا كانت الشقة موجودة بالفعل في المفضلة
    isFavorite = FavoritesScreen.favoriteApartments.any(
      (apt) => apt['title'] == widget.apartment['title'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;

    // قائمة الصور المحلية
    /* final List<String> images = [
      'assets/images/apartment1_1.jpg',
      'assets/images/apartment1_2.jpg',
      'assets/images/apartment1_3.jpg',
    ];*/

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      body: Column(
        children: [
          // ----------- IMAGES (PageView) -----------
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                /*PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),*/
                // BACK BUTTON
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
                // FAVORITE
                Positioned(
                  top: 40,
                  right: 20,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;

                        if (isFavorite) {
                          // إضافة الشقة للمفضلة إذا لم تكن موجودة مسبقًا
                          if (!FavoritesScreen.favoriteApartments.any(
                            (apt) => apt['title'] == apartment['title'],
                          )) {
                            /* final aptWithImages = Map<String, dynamic>.from(
                              apartment,
                            );
                            aptWithImages['images'] = images;
                            FavoritesScreen.favoriteApartments.add(
                              aptWithImages,
                            );*/
                          }
                        } else {
                          // إزالة الشقة من المفضلة
                          FavoritesScreen.favoriteApartments.removeWhere(
                            (apt) => apt['title'] == apartment['title'],
                          );
                        }
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                // INDICATORS
                /*Positioned(
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
                          color:
                              _currentPage == index
                                  ? Colors.white
                                  : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),

          // ----------- DETAILS -----------
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                      "شقة رائعة تقع في ${apartment['city']} بمواصفات ممتازة.",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    _info(Icons.location_on, apartment['city']),
                    _info(Icons.crop_square, "${apartment['area']} متر مربع"),
                    _info(Icons.attach_money, "${apartment['price']} \$ / شهر"),
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
                                  builder:
                                      (context) => FullBookingPage(
                                        // ✅ إضافة جميع المعلمات المطلوبة
                                        pricePerDay:
                                            apartment['price'].toDouble(),
                                        apartmentId:
                                            apartment['id']
                                                .toString(), // ✅ مطلوب
                                        apartmentName:
                                            apartment['name']?.toString() ??
                                            'شقة', // ✅ مطلوب
                                        apartmentImage:
                                            apartment['image']?.toString() ??
                                            'assets/default.jpg',
                                        // ✅ مطلوب
                                        apartmentLocation:
                                            apartment['location']?.toString() ??
                                            'موقع غير محدد', // ✅ مطلوب
                                      ),
                                ),
                              );
                            },
                            child: const Text("حجز الآن"),
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
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
