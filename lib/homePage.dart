// apartment_booking_screen.dart
import 'package:flutter/material.dart';

import 'package:flutter_application_8/buildEndDrower.dart';
import 'package:flutter_application_8/constants.dart';

import 'AppartementDetails.dart';

class ApartmentBookingScreen extends StatefulWidget {
  const ApartmentBookingScreen({super.key});

  @override
  State<ApartmentBookingScreen> createState() => _ApartmentBookingScreenState();
}

class _ApartmentBookingScreenState extends State<ApartmentBookingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'All Cities';
  String _selectedPriceRange = 'Any Price';
  String _selectedAreaRange = 'Any Area';
  bool _showAllApartments = false;
  bool _isEnglish = true;
  bool _isDarkMode = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _cities = [
    'All Cities',
    'New York',
    'Los Angeles',
    'Chicago',
    'Miami',
    'Dubai',
    'London',
    'Paris',
  ];

  final List<String> _priceRanges = [
    'Any Price',
    '\$500 - \$1,000',
    '\$1,000 - \$1,500',
    '\$1,500 - \$2,000',
    '\$2,000+',
  ];

  final List<String> _areaRanges = [
    'Any Area',
    '500 - 1,000 sq ft',
    '1,000 - 1,500 sq ft',
    '1,500 - 2,000 sq ft',
    '2,000+ sq ft',
  ];

  // بيانات الشقق (في التطبيق الحقيقي قد تأتي من API)
  // بيانات الشقق المحسنة
  final List<Map<String, dynamic>> _allApartments = [
    {
      'id': 1,
      'title': 'Central Park View Apartment',
      'city': 'New York',
      'price': 1200,
      'area': 800,
      'image':
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&fit=crop',
      'description': 'شقة فاخرة مع إطلالة رائعة على سنترال بارك',
      'fallbackColor': Colors.blue[100],
    },
    {
      'id': 2,
      'title': 'Luxury Downtown Apartment',
      'city': 'Los Angeles',
      'price': 1800,
      'area': 1200,
      'image':
          'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=600&fit=crop',
      'description': 'شقة حديثة في وسط المدينة مع وسائل راحة متطورة',
      'fallbackColor': Colors.orange[100],
    },
    {
      'id': 3,
      'title': 'Modern City Center Studio',
      'city': 'Chicago',
      'price': 900,
      'area': 600,
      'image':
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&fit=crop',
      'description': 'استوديو عصري في قلب شيكاغو',
      'fallbackColor': Colors.grey[200],
    },
    {
      'id': 4,
      'title': 'Beachfront Miami Condo',
      'city': 'Miami',
      'price': 2200,
      'area': 1500,
      'image':
          'https://images.unsplash.com/photo-1494526585095-c41746248156?w=600&fit=crop',
      'description': 'كوندو مع إطلالة مباشرة على الشاطئ',
      'fallbackColor': Colors.lightBlue[100],
    },
    {
      'id': 5,
      'title': 'Luxury Dubai Penthouse',
      'city': 'Dubai',
      'price': 3000,
      'area': 2000,
      'image':
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=600&fit=crop',
      'description': 'بنتهاوس فاخر مع إطلالة بانورامية على المدينة',
      'fallbackColor': Colors.amber[100],
    },
    {
      'id': 6,
      'title': 'Historic London Flat',
      'city': 'London',
      'price': 1600,
      'area': 900,
      'image':
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&fit=crop',
      'description': 'شقة تاريخية في حي لندني تقليدي',
      'fallbackColor': Colors.brown[100],
    },
    {
      'id': 7,
      'title': 'Chic Parisian Apartment',
      'city': 'Paris',
      'price': 1400,
      'area': 750,
      'image':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&fit=crop',
      'description': 'شقة أنيقة في قلب باريس',
      'fallbackColor': Colors.pink[100],
    },
    {
      'id': 8,
      'title': 'Spacious New York Loft',
      'city': 'New York',
      'price': 2500,
      'area': 1800,
      'image':
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&fit=crop',
      'description': 'لوفت واسع بتصميم صناعي عصري',
      'fallbackColor': Colors.indigo[100],
    },
  ];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة الفلترة
  List<Map<String, dynamic>> get _filteredApartments {
    if (_showAllApartments) {
      return _allApartments;
    }

    return _allApartments.where((apartment) {
      // فلترة المدينة
      bool cityMatch =
          _selectedCity == 'All Cities' || apartment['city'] == _selectedCity;

      // فلترة السعر
      bool priceMatch = true;
      switch (_selectedPriceRange) {
        case '\$500 - \$1,000':
          priceMatch = apartment['price'] >= 500 && apartment['price'] <= 1000;
          break;
        case '\$1,000 - \$1,500':
          priceMatch = apartment['price'] >= 1000 && apartment['price'] <= 1500;
          break;
        case '\$1,500 - \$2,000':
          priceMatch = apartment['price'] >= 1500 && apartment['price'] <= 2000;
          break;
        case '\$2,000+':
          priceMatch = apartment['price'] >= 2000;
          break;
        default:
          priceMatch = true;
      }

      // فلترة المساحة
      bool areaMatch = true;
      switch (_selectedAreaRange) {
        case '500 - 1,000 sq ft':
          areaMatch = apartment['area'] >= 500 && apartment['area'] <= 1000;
          break;
        case '1,000 - 1,500 sq ft':
          areaMatch = apartment['area'] >= 1000 && apartment['area'] <= 1500;
          break;
        case '1,500 - 2,000 sq ft':
          areaMatch = apartment['area'] >= 1500 && apartment['area'] <= 2000;
          break;
        case '2,000+ sq ft':
          areaMatch = apartment['area'] >= 2000;
          break;
        default:
          areaMatch = true;
      }

      // فلترة البحث - التعديل هنا
      bool searchMatch =
          _searchController.text.isEmpty ||
          _doesApartmentMatchSearch(
            apartment,
            _searchController.text.toLowerCase(),
          );

      return cityMatch && priceMatch && areaMatch && searchMatch;
    }).toList();
  }

  // دالة البحث المحسنة
  bool _doesApartmentMatchSearch(
    Map<String, dynamic> apartment,
    String searchText,
  ) {
    if (searchText.isEmpty) return true;

    final title = apartment['title'].toString().toLowerCase();
    final city = apartment['city'].toString().toLowerCase();

    // تقسيم نص البحث إلى كلمات فردية
    final searchWords = searchText.split(' ');

    // التحقق إذا كانت أي من كلمات البحث موجودة في العنوان أو المدينة
    for (final word in searchWords) {
      if (word.isNotEmpty && (title.contains(word) || city.contains(word))) {
        return true;
      }
    }

    return false;
  }

  // دالة إعادة تعيين الفلترة
  void _resetFilters() {
    setState(() {
      _selectedCity = 'All Cities';
      _selectedPriceRange = 'Any Price';
      _selectedAreaRange = 'Any Area';
      _showAllApartments = false;
      _searchController.clear();
    });
  }

  // دالة لتغيير اللغة
  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  // دالة لتغيير الوضع
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,

      // AppBar
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.grey[900] : accentColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.home_rounded,
              color: _isDarkMode ? Colors.white : accentColor,
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish ? 'Welcome' : 'أهلاً بك',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _isEnglish
                  ? 'Find your dream apartment'
                  : 'ابحث عن شقتك المثالية',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // زر تبديل المظهر
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _toggleTheme,
              tooltip: _isEnglish ? 'Toggle theme' : 'تبديل المظهر',
            ),
          ),
          // زر تبديل اللغة
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isEnglish ? Icons.language : Icons.translate,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _toggleLanguage,
              tooltip: _isEnglish ? 'Change language' : 'تغيير اللغة',
            ),
          ),
          // زر القائمة
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 22),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      endDrawer: EndDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Search and Filter Section
              _buildSearchFilterSection(),
              const SizedBox(height: 16),

              // Selected Filters Indicators
              _buildFilterIndicators(),
              const SizedBox(height: 8),

              _buildCategoriesSection(),
              const SizedBox(height: 24),

              // Upgrade Plan
              _buildUpgradePlan(),
              const SizedBox(height: 24),

              // Apartments Grid
              _buildApartmentsGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 3,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          _isEnglish
                              ? 'Search by title or city...'
                              : 'ابحث بالعنوان أو المدينة...',
                      hintStyle: TextStyle(
                        color:
                            _isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _showAllApartments = false;
                      });
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _showAllApartments = false;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filter Button
        Expanded(
          flex: 1,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor),
            ),
            child: InkWell(
              onTap: () {
                _showFilterDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_outlined, color: accentColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _isEnglish ? 'Filter' : 'تصفية',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSelectedCity = _selectedCity;
        String tempSelectedPriceRange = _selectedPriceRange;
        String tempSelectedAreaRange = _selectedAreaRange;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
              title: Text(
                _isEnglish ? 'Filter Apartments' : 'تصفية الشقق',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Filter
                    _buildFilterSection(
                      _isEnglish ? 'City' : 'المدينة',
                      tempSelectedCity,
                      _cities,
                      (value) {
                        setStateDialog(() {
                          tempSelectedCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price Filter
                    _buildFilterSection(
                      _isEnglish ? 'Price Range' : 'نطاق السعر',
                      tempSelectedPriceRange,
                      _priceRanges,
                      (value) {
                        setStateDialog(() {
                          tempSelectedPriceRange = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Area Filter
                    _buildFilterSection(
                      _isEnglish ? 'Area' : 'المساحة',
                      tempSelectedAreaRange,
                      _areaRanges,
                      (value) {
                        setStateDialog(() {
                          tempSelectedAreaRange = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setStateDialog(() {
                      tempSelectedCity = 'All Cities';
                      tempSelectedPriceRange = 'Any Price';
                      tempSelectedAreaRange = 'Any Area';
                    });
                  },
                  child: Text(
                    _isEnglish ? 'Reset All' : 'إعادة التعيين',
                    style: TextStyle(
                      color: Colors.black,
                    ), // إضافة اللون الأسود للنص
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // اللون عند الضغط
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    _isEnglish ? 'Cancel' : 'إلغاء',
                    style: TextStyle(
                      color: Colors.black,
                    ), // إضافة اللون الأسود للنص
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // اللون عند الضغط
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // تطبيق الفلترة مباشرة
                    setState(() {
                      _selectedCity = tempSelectedCity;
                      _selectedPriceRange = tempSelectedPriceRange;
                      _selectedAreaRange = tempSelectedAreaRange;
                      _showAllApartments = false;
                    });
                  },
                  child: Text(
                    _isEnglish ? 'Apply Filters' : 'تطبيق التصفية',
                    style: TextStyle(color: Colors.white), // النص أبيض للتباين
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, // الخلفية سوداء
                    foregroundColor: Colors.white, // اللون عند الضغط
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedValue == option;
                return ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      color:
                          isSelected
                              ? (_isDarkMode ? Colors.black : Colors.white)
                              : (_isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    onChanged(option);
                  },
                  selectedColor: accentColor,
                  backgroundColor:
                      _isDarkMode ? Colors.grey[700] : Colors.grey[200],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterIndicators() {
    final List<Widget> indicators = [];

    if (_selectedCity != 'All Cities') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'City' : 'المدينة'}: $_selectedCity',
          () {
            setState(() {
              _selectedCity = 'All Cities';
              _showAllApartments = false;
            });
          },
        ),
      );
    }

    if (_selectedPriceRange != 'Any Price') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'Price' : 'السعر'}: $_selectedPriceRange',
          () {
            setState(() {
              _selectedPriceRange = 'Any Price';
              _showAllApartments = false;
            });
          },
        ),
      );
    }

    if (_selectedAreaRange != 'Any Area') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'Area' : 'المساحة'}: $_selectedAreaRange',
          () {
            setState(() {
              _selectedAreaRange = 'Any Area';
              _showAllApartments = false;
            });
          },
        ),
      );
    }

    if (indicators.isNotEmpty) {
      return Wrap(spacing: 8, runSpacing: 8, children: indicators);
    }

    return const SizedBox();
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[700] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, color: accentColor, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          _isEnglish
              ? 'What apartment are we booking today?'
              : 'ما الشقة التي سنحجزها اليوم؟',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? Colors.white : Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEnglish ? 'Categories' : 'الفئات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(_isEnglish ? 'Studios' : 'استوديوهات'),
              const SizedBox(width: 8),
              _buildCategoryChip(_isEnglish ? 'Utility' : 'خدمية'),
              const SizedBox(width: 8),
              _buildCategoryChip(_isEnglish ? 'Family' : 'عائلية'),
              const SizedBox(width: 8),
              _buildCategoryChip(_isEnglish ? 'Condos' : 'شقق'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUpgradePlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isEnglish ? 'UPGRADE PLAN' : 'ترقية الخطة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.grey[700],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAllApartments = true;
                });
              },
              child: Text(
                _isEnglish ? 'View all' : 'عرض الكل',
                style: TextStyle(
                  fontSize: 14,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildApartmentsGrid() {
    final apartments = _filteredApartments;

    if (apartments.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: _isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isEnglish ? 'No apartments found' : 'لم يتم العثور على شقق',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEnglish
                  ? 'Try adjusting your search or filters'
                  : 'حاول تعديل البحث أو التصفيات',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAllApartments = true;
                });
              },
              child: Text(
                _isEnglish ? 'View All Apartments' : 'عرض جميع الشقق',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showAllApartments)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  _isEnglish ? 'Showing all apartments' : 'عرض جميع الشقق',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllApartments = false;
                    });
                  },
                  child: Text(_isEnglish ? 'Show Filtered' : 'عرض المفلتر'),
                ),
              ],
            ),
          ),
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  _isEnglish
                      ? 'Search results for "${_searchController.text}"'
                      : 'نتائج البحث عن "${_searchController.text}"',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: apartments.length,
          itemBuilder: (context, index) {
            final apartment = apartments[index];

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApartmentDetailsPage(apartment: apartment),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الشقة
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.home,
                          color: Colors.blueGrey[400],
                          size: 40,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // الموقع مع أيقونة
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                apartment['city'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // المساحة مع أيقونة
                          Row(
                            children: [
                              Icon(
                                Icons.aspect_ratio_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${apartment['area']} sq ft',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // السعر مع أيقونة
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money_outlined,
                                size: 14,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${apartment['price']} / month',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
      ],
    );
  }
}
