import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> apartments;

  const FavoritesScreen({super.key, required this.apartments});

  @override
  Widget build(BuildContext context) {
    final favoriteApartments =
        apartments.where((apt) => apt['isFavorite']).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: accentColor,
      ),
      body:
          favoriteApartments.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add apartments to your favorites',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteApartments.length,
                itemBuilder: (context, index) {
                  final apartment = favoriteApartments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        apartment['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(apartment['title']),
                      subtitle: Text(
                        '${apartment['city']} • \$${apartment['price']}/month',
                      ),
                      trailing: Icon(Icons.favorite, color: Colors.red),
                    ),
                  );
                },
              ),
    );
  }
}

// صفحة الحجوزات
