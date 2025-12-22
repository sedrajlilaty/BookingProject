import 'package:flutter/material.dart';

import '../../constants.dart';
import 'AppartementDetails.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  static List<Map<String, dynamic>> favoriteApartments = [];

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScreen.favoriteApartments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: accentColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            favorites.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد شقق مفضلة بعد',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدأ بإضافة شقق إلى قائمة المفضلة',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final apt = favorites[index];
                    final images = apt['images'] as List<String>? ?? [];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ApartmentDetailsPage(apartment: apt),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🟢 الصورة
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      images.isNotEmpty
                                          ? images[0]
                                          : 'assets/images/placeholder.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),

                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          FavoritesScreen.favoriteApartments
                                              .removeAt(index);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🟢 التفاصيل
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt['title'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    apt['city'],
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${apt['price']} \$ / شهر",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
