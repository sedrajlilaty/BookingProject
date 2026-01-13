import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/my_appartment_model.dart';
import 'package:flutter_application_8/services/favorateSErves.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../constants.dart';
import 'AppartementDetails.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // تعريف الخدمة لجلب البيانات من السيرفر
  final FavoriteService _favoriteService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        // إعدادات الألوان بناءً على حالة الثيم
        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.white;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color subtitleColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;
        Color iconBgColor = isDark ? Colors.grey[700]! : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              isDark ? 'المفضلة' : 'Favorites',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: accentColor,
            centerTitle: true,
            elevation: 4,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          // استخدام FutureBuilder لجلب الشقق من السيرفر
          body: FutureBuilder<List<dynamic>>(
            future: _favoriteService.getAllFavorites(),
            builder: (context, snapshot) {
              // 1. حالة التحميل
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. حالة الخطأ أو القائمة فارغة
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return _buildEmptyState(isDark);
              }

              // 3. حالة نجاح جلب البيانات
              final favorites = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final apt = favorites[index];
                    return _buildApartmentCard(
                      apt,
                      cardColor,
                      textColor,
                      subtitleColor,
                      iconBgColor,
                      isDark,
                      index,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // واجهة عرض القائمة الفارغة
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'there is no favorate appartement',
            style: TextStyle(
              fontSize: 20,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "start adding your favorate appartement",
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(
    Map<String, dynamic> apartment,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Color iconBgColor,
    bool isDark,
    int index,
  ) {
    final model = ApartmentModel.fromJson(
      apartment,
    ); // تحويل الـ Map لموديل فوراً
    final imageUrl =
        model.images.isNotEmpty
            ? model.images[0].image
            : 'https://via.placeholder.com/150';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Convert map to ApartmentModel and navigate to details
        try {
          final apartmentModel = ApartmentModel.fromJson(apartment);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ApartmentDetailsPage(apartment: apartmentModel),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('error in loading appartement')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),

                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: iconBgColor,
                    child: const Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment['name'] ?? 'without name',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        apartment['city'] ?? '  unkonown location',
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${apartment['price'] ?? 0} / month',
                    style: TextStyle(
                      fontSize: 12,
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
  }

  Future<bool> isFavorite(int apartmentId) async {
    try {
      List<dynamic> favorites = await _favoriteService.getAllFavorites();
      // نتحقق إذا كان معرف الشقة موجود في القائمة المسترجعة من السيرفر
      return favorites.any((item) => item['id'] == apartmentId);
    } catch (e) {
      return false;
    }
  }
}
