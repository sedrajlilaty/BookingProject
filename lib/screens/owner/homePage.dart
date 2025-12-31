import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_8/screens/buildEndDrower.dart';
import 'package:flutter_application_8/constants.dart';

import '../../Notifaction.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../cubit/appartment_cubit_cubit.dart';
import '../../models/my_appartment_model.dart';
import '../tanent/AppartementDetails.dart';

class ApartmentBookingScreen extends StatefulWidget {
  final bool isOwner; // يجب تمريره من الخارج

  const ApartmentBookingScreen({super.key, required this.isOwner});

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

  List<Map<String, dynamic>> get _filteredApartments {
    if (_showAllApartments) return _allApartments;

    return _allApartments.where((apartment) {
      bool cityMatch =
          _selectedCity == 'All Cities' || apartment['city'] == _selectedCity;
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

      bool searchMatch =
          _searchController.text.isEmpty ||
          _doesApartmentMatchSearch(
            apartment,
            _searchController.text.toLowerCase(),
          );

      return cityMatch && priceMatch && areaMatch && searchMatch;
    }).toList();
  }

  bool _doesApartmentMatchSearch(
    Map<String, dynamic> apartment,
    String searchText,
  ) {
    if (searchText.isEmpty) return true;

    final title = apartment['title'].toLowerCase();
    final city = apartment['city'].toLowerCase();

    final searchWords = searchText.split(' ');

    for (final word in searchWords) {
      if (word.isNotEmpty && (title.contains(word) || city.contains(word))) {
        return true;
      }
    }

    return false;
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = 'All Cities';
      _selectedPriceRange = 'Any Price';
      _selectedAreaRange = 'Any Area';
      _showAllApartments = false;
      _searchController.clear();
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final bool isDark = state is DarkState;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          appBar: AppBar(
            title: const Text(
              'Home page',
              style: TextStyle(
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

            // ⬅️ اليسار
            leadingWidth: 110,
            leading: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white,
                  ),
                  onPressed: () => context.read<ThemeCubit>().changeTheme(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isEnglish ? Icons.language : Icons.translate,
                    color: Colors.white,
                  ),
                  onPressed: _toggleLanguage,
                ),
              ],
            ),

            // ➡️ اليمين
            actions: [
              const SizedBox(width: 48), // 🔑 حجز مساحة مساوية لليسار
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),

          endDrawer: EndDrawer(),
          body: BlocProvider(
            create: (context) => AppartmentCubit()..getMyApartment(),
            child: BlocConsumer<AppartmentCubit, AppartmentState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                var cubit = AppartmentCubit.get(context);

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isDark),
                        const SizedBox(height: 24),
                        _buildSearchFilterSection(isDark),
                        const SizedBox(height: 16),
                        _buildFilterIndicators(isDark),
                        const SizedBox(height: 8),
                        _buildCategoriesSection(isDark),
                        const SizedBox(height: 24),
                        _buildUpgradePlan(isDark),
                        const SizedBox(height: 24),
                        state is AppartmentLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildApartmentsGrid(isDark, cubit.appartments),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Text(
      _isEnglish
          ? 'What apartment are we booking today?'
          : 'ما الشقة التي سنحجزها اليوم؟',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.grey[700],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEnglish ? 'Categories' : 'الفئات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
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
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUpgradePlan(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isEnglish ? 'UPGRADE PLAN' : 'ترقية الخطة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[700],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _showAllApartments = true),
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
    );
  }

  Widget _buildFilterIndicators(bool isDark) {
    final List<Widget> indicators = [];

    if (_selectedCity != 'All Cities') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'City' : 'المدينة'}: $_selectedCity',
          isDark,
          () {
            setState(() => _selectedCity = 'All Cities');
          },
        ),
      );
    }

    if (_selectedPriceRange != 'Any Price') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'Price' : 'السعر'}: $_selectedPriceRange',
          isDark,
          () {
            setState(() => _selectedPriceRange = 'Any Price');
          },
        ),
      );
    }

    if (_selectedAreaRange != 'Any Area') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'Area' : 'المساحة'}: $_selectedAreaRange',
          isDark,
          () {
            setState(() => _selectedAreaRange = 'Any Area');
          },
        ),
      );
    }

    return indicators.isNotEmpty
        ? Wrap(spacing: 8, children: indicators)
        : const SizedBox();
  }

  Widget _buildFilterChip(String label, bool isDark, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.blue[50],
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

  Widget _buildSearchFilterSection(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onChanged:
                        (value) => setState(() => _showAllApartments = false),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed:
                        () => setState(() {
                          _searchController.clear();
                          _showAllApartments = false;
                        }),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: _showFilterDialog,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_outlined, color: accentColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _isEnglish ? 'Filter' : 'تصفية',
                    style: TextStyle(color: accentColor),
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
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                final isDark = state is DarkState;

                return AlertDialog(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  title: Text(
                    _isEnglish ? 'Filter Apartments' : 'تصفية الشقق',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          _isEnglish ? 'City' : 'المدينة',
                          tempSelectedCity,
                          _cities,
                          isDark,
                          (value) {
                            setStateDialog(() {
                              tempSelectedCity = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFilterSection(
                          _isEnglish ? 'Price Range' : 'نطاق السعر',
                          tempSelectedPriceRange,
                          _priceRanges,
                          isDark,
                          (value) {
                            setStateDialog(() {
                              tempSelectedPriceRange = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFilterSection(
                          _isEnglish ? 'Area' : 'المساحة',
                          tempSelectedAreaRange,
                          _areaRanges,
                          isDark,
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
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        _isEnglish ? 'Cancel' : 'إلغاء',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCity = tempSelectedCity;
                          _selectedPriceRange = tempSelectedPriceRange;
                          _selectedAreaRange = tempSelectedAreaRange;
                          _showAllApartments = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        _isEnglish ? 'Apply Filters' : 'تطبيق التصفية',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
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
    bool isDark,
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
            color: isDark ? Colors.white : Colors.black,
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
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => onChanged(option),
                  selectedColor: accentColor,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildApartmentsGrid(bool isDark, List<ApartmentModel> appartments) {
    // final apartments = _filteredApartments;

    if (appartments.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isEnglish ? 'No apartments found' : 'لم يتم العثور على شقق',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEnglish
                  ? 'Try adjusting your search or filters'
                  : 'حاول تعديل البحث أو التصفيات',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _showAllApartments = true);
              },
              child: Text(
                _isEnglish ? 'View All Apartments' : 'عرض جميع الشقق',
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: appartments.length,
      itemBuilder: (context, index) {
        final apartment = appartments[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ApartmentDetailsPage(apartment: appartments[index]),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        appartments[index].name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appartments[index].city,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.aspect_ratio_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${appartments[index].area} sq ft',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_outlined,
                            size: 14,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${appartments[index].price} / month',
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
    );
  }
}
