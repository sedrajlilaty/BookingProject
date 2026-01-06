import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/notificationProvider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_8/screens/buildEndDrower.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:provider/provider.dart';

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
  String _selectedRoomsRange = 'Any Rooms';
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

  final List<String> _roomsRanges = [
    'Any Rooms',
    '1 Room',
    '2 Rooms',
    '3 Rooms',
    '4+ Rooms',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApartmentModel> _filterApartments(List<ApartmentModel> apartments) {
    if (_showAllApartments) return apartments;

    return apartments.where((apartment) {
      // فلترة المدينة
      bool cityMatch =
          _selectedCity == 'All Cities' || apartment.city == _selectedCity;

      // فلترة السعر
      bool priceMatch = true;
      switch (_selectedPriceRange) {
        case '\$500 - \$1,000':
          priceMatch = apartment.price >= 500 && apartment.price <= 1000;
          break;
        case '\$1,000 - \$1,500':
          priceMatch = apartment.price >= 1000 && apartment.price <= 1500;
          break;
        case '\$1,500 - \$2,000':
          priceMatch = apartment.price >= 1500 && apartment.price <= 2000;
          break;
        case '\$2,000+':
          priceMatch = apartment.price >= 2000;
          break;
        default:
          priceMatch = true;
      }

      // فلترة المساحة
      bool areaMatch = true;
      switch (_selectedAreaRange) {
        case '500 - 1,000 sq ft':
          areaMatch = apartment.area >= 500 && apartment.area <= 1000;
          break;
        case '1,000 - 1,500 sq ft':
          areaMatch = apartment.area >= 1000 && apartment.area <= 1500;
          break;
        case '1,500 - 2,000 sq ft':
          areaMatch = apartment.area >= 1500 && apartment.area <= 2000;
          break;
        case '2,000+ sq ft':
          areaMatch = apartment.area >= 2000;
          break;
        default:
          areaMatch = true;
      }

      // فلترة عدد الغرف
      bool roomsMatch = true;
      switch (_selectedRoomsRange) {
        case '1 Room':
          roomsMatch = apartment.rooms == 1;
          break;
        case '2 Rooms':
          roomsMatch = apartment.rooms == 2;
          break;
        case '3 Rooms':
          roomsMatch = apartment.rooms == 3;
          break;
        case '4+ Rooms':
          roomsMatch = apartment.rooms >= 4;
          break;
        default:
          roomsMatch = true;
      }

      // فلترة البحث
      bool searchMatch =
          _searchController.text.isEmpty ||
          _doesApartmentMatchSearch(
            apartment,
            _searchController.text.toLowerCase(),
          );

      return cityMatch && priceMatch && areaMatch && roomsMatch && searchMatch;
    }).toList();
  }

  bool _doesApartmentMatchSearch(ApartmentModel apartment, String searchText) {
    if (searchText.isEmpty) return true;

    final name = apartment.name.toLowerCase();
    final city = apartment.city.toLowerCase();
    final governorate = apartment.governorate.toLowerCase() ?? '';
    final description = apartment.description.toLowerCase() ?? '';

    final searchWords = searchText.split(' ');

    for (final word in searchWords) {
      if (word.isNotEmpty &&
          (name.contains(word) ||
              city.contains(word) ||
              governorate.contains(word) ||
              description.contains(word))) {
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
      _selectedRoomsRange = 'Any Rooms';
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
            // في قسم actions اليمين داخل الـ AppBar
            actions: [
              const SizedBox(width: 48),
              // 🔔 أيقونة الإشعارات مع العداد
              Consumer<NotificationProvider>(
                builder: (context, notiProvider, child) {
                  return Badge(
                    label: Text(
                      notiProvider.unreadCount.toString(),
                      style: const TextStyle(color: accentColor, fontSize: 10),
                    ),
                    // يظهر العداد فقط إذا كان هناك إشعارات غير مقروءة
                    isLabelVisible: notiProvider.unreadCount > 0,
                    backgroundColor: cardBackgroundColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),

          endDrawer: EndDrawer(),
          body: BlocProvider(
            create:
                widget.isOwner
                    ? (context) => AppartmentCubit()..getMyApartment()
                    : (context) => AppartmentCubit()..getAllApartment(),
            child: BlocConsumer<AppartmentCubit, AppartmentState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                var cubit = AppartmentCubit.get(context);
                final apartments =
                    widget.isOwner ? cubit.myappartments : cubit.appartments;
                final filteredApartments = _filterApartments(apartments);

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
                            : _buildApartmentsGrid(isDark, filteredApartments),
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

    if (_selectedRoomsRange != 'Any Rooms') {
      indicators.add(
        _buildFilterChip(
          '${_isEnglish ? 'Rooms' : 'الغرف'}: $_selectedRoomsRange',
          isDark,
          () {
            setState(() => _selectedRoomsRange = 'Any Rooms');
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
                              ? 'Search by name, city, governorate...'
                              : 'ابحث بالاسم، المدينة، المحافظة...',
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
        String tempSelectedRoomsRange = _selectedRoomsRange;

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
                        const SizedBox(height: 16),
                        _buildFilterSection(
                          _isEnglish ? 'Number of Rooms' : 'عدد الغرف',
                          tempSelectedRoomsRange,
                          _roomsRanges,
                          isDark,
                          (value) {
                            setStateDialog(() {
                              tempSelectedRoomsRange = value;
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
                          tempSelectedRoomsRange = 'Any Rooms';
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
                          _selectedRoomsRange = tempSelectedRoomsRange;
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

  Widget _buildApartmentsGrid(bool isDark, List<ApartmentModel> apartments) {
    if (apartments.isEmpty) {
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
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        final apartment = apartments[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ApartmentDetailsPage(apartment: apartments[index]),
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
                        apartment.name,
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
                          Flexible(
                            child: Text(
                              apartment.city,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                            '${apartment.area} sq ft',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.bed_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${apartment.rooms} rooms',
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
                            '${apartment.price} / month',
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
