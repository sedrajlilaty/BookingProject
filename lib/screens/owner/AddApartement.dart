import 'package:flutter/material.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/screens/cubit/appartment_cubit_cubit.dart';
import 'package:flutter_application_8/screens/owner/doneAdd.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';
import '../../models/booking_model.dart' hide Apartment;
import '../widgets/dotted_container_add_images_widget.dart';
import '../widgets/list_of_image.dart';

class AddApartmentScreen extends StatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _titleController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();
  final _discController = TextEditingController();
  final _nameController = TextEditingController();

  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  AppartmentCubit appartmentCubit = AppartmentCubit();
  final List<String> _governorates = [
    'الرياض',
    'مكة المكرمة',
    'المدينة المنورة',
    'الشرقية',
    'القصيم',
    'عسير',
    'تبوك',
    'حائل',
    'الحدود الشمالية',
    'جازان',
    'نجران',
    'الباحة',
    'الجوف',
  ];

  List<String> _cities = [];
  String? _selectedGovernorate;
  String? _selectedCity;
  String? _apartmentType;
  final List<String> _apartmentTypes = [
    'apartment',
    'استوديو',
    'فيلا',
    'دوبلكس',
  ];

  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  List<Apartment> _allApartments = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submit() async {
    if (_nameController.text.isEmpty ||
        _roomsController.text.isEmpty ||
        _bathroomsController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _discController.text.isEmpty ||
        _apartmentType == null ||
        _selectedGovernorate == null ||
        _selectedCity == null ||
        _selectedImages.isEmpty) {
      String errorMessage = 'الرجاء تعبئة جميع الحقول الإلزامية:\n';
      if (_apartmentType == null) errorMessage += '• نوع الشقة\n';
      if (_nameController.text.isEmpty) errorMessage += '• اسم الشقة\n';
      if (_selectedGovernorate == null) errorMessage += '• المحافظة\n';
      if (_selectedCity == null) errorMessage += '• المدينة\n';
      if (_selectedImages.isEmpty) errorMessage += '• إضافة صور للشقة\n';
      if (_priceController.text.isEmpty) errorMessage += '• السعر\n';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newApartment = Apartment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _apartmentType!,
        governorate: _selectedGovernorate!,
        city: _selectedCity!,
        detailedLocation:
            _titleController.text.trim().isEmpty
                ? null
                : _titleController.text.trim(),
        rooms: int.tryParse(_roomsController.text) ?? 0,
        bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
        area: double.tryParse(_areaController.text) ?? 0.0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _discController.text.trim(),
        images: _selectedImages.map((image) => image.path).toList(),
        createdAt: DateTime.now(),
      );

      final uploadedImages = await _uploadImages(_selectedImages);
      _allApartments.add(newApartment);

      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoneAdd()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];
    return uploadedUrls;
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    Color fillColor,
    Color borderColor,
    Color focusBorderColor,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: fillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusBorderColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildApartmentTypeChip(
    String text,
    Color textColor,
    Color chipColor, {
    required ValueChanged<String> onTap,
  }) {
    final bool isSelected = _apartmentType == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          _apartmentType = text;
        });
        onTap(text); // هون بترجع القيمة
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : chipColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor, width: 2),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : [],
        ),
        transform:
            isSelected ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildImagesGrid(Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'الصور المضافة (${_selectedImages.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedImages.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 50, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  'لم يتم إضافة صور',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() {
    setState(() {
      _cities = [
        'المدينة الرئيسية',
        'المدينة الفرعية 1',
        'المدينة الفرعية 2',
        'المدينة الفرعية 3',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;
        Color backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
        Color fieldColor = isDark ? Colors.grey[800]! : Colors.white;
        Color borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
        Color textColor = isDark ? Colors.white : Colors.black;
        Color chipColor = isDark ? Colors.grey[700]! : Colors.white;
        Color cardColor = isDark ? Colors.grey[800]! : Colors.grey[50]!;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text(
                'إضافة شقة',
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
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            body: BlocProvider(
              create: (context) => AppartmentCubit(),
              child: BlocConsumer<AppartmentCubit, AppartmentState>(
                listener: (context, state) {
                  if (state is AppartmentSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DoneAdd()),
                    );
                  } else if (state is AppartmentCubitError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  var cubit = AppartmentCubit.get(context);
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          child: Form(
                            key: cubit.formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.category, color: accentColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'نوع الشقة',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          _apartmentTypes
                                              .map(
                                                (type) =>
                                                    _buildApartmentTypeChip(
                                                      onTap: (value) {
                                                        cubit
                                                            .typeController
                                                            .text = value;
                                                      },
                                                      type,
                                                      textColor,
                                                      chipColor,
                                                    ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'صور الشقة',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                ListOfImage(
                                  images: cubit.images,
                                  appartmentCubit: cubit,
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: DottedContainerAddImagesWidget(
                                    function: () => cubit.showPicker(context),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Icon(Icons.apartment, color: accentColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تفاصيل الشقة',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: cubit.nameController,
                                  decoration: _inputDecoration(
                                    'اسم الشقة *',
                                    Icons.home,
                                    fieldColor,
                                    borderColor,
                                    accentColor,
                                  ),
                                  style: TextStyle(color: textColor),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedGovernorate,
                                  decoration: _inputDecoration(
                                    'اختر المحافظة *',
                                    Icons.location_city,
                                    fieldColor,
                                    borderColor,
                                    accentColor,
                                  ),
                                  items:
                                      _governorates.map((governorate) {
                                        return DropdownMenuItem(
                                          value: governorate,
                                          child: Text(
                                            governorate,
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      cubit.governorateController.text =
                                          value ?? '';
                                      _selectedGovernorate = value;
                                      _selectedCity = null;
                                      _loadCities();
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedCity,
                                  decoration: _inputDecoration(
                                    'اختر المدينة *',
                                    Icons.location_on,
                                    fieldColor,
                                    borderColor,
                                    accentColor,
                                  ),
                                  items:
                                      _cities.map((city) {
                                        return DropdownMenuItem(
                                          value: city,
                                          child: Text(
                                            city,
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged:
                                      _selectedGovernorate == null
                                          ? null
                                          : (value) {
                                            setState(() {
                                              cubit.cityController.text =
                                                  value ?? '';
                                              _selectedCity = value;
                                            });
                                          },
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: cubit.locationController,
                                  decoration: _inputDecoration(
                                    'الموقع التفصيلي',
                                    Icons.location_pin,
                                    fieldColor,
                                    borderColor,
                                    accentColor,
                                  ),
                                  style: TextStyle(color: textColor),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: cubit.roomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(
                                          'عدد الغرف',
                                          Icons.bed,
                                          fieldColor,
                                          borderColor,
                                          accentColor,
                                        ),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: cubit.bathroomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(
                                          'عدد الحمامات',
                                          Icons.bathtub,
                                          fieldColor,
                                          borderColor,
                                          accentColor,
                                        ),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: cubit.descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    'وصف الشقة',
                                    Icons.description,
                                    fieldColor,
                                    borderColor,
                                    accentColor,
                                  ),
                                  style: TextStyle(color: textColor),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: cubit.areaController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(
                                          'المساحة',
                                          Icons.square_foot,
                                          fieldColor,
                                          borderColor,
                                          accentColor,
                                        ),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: cubit.priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(
                                          'السعر  *',
                                          Icons.price_change,
                                          fieldColor,
                                          borderColor,
                                          accentColor,
                                        ),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () {
                                              cubit.addAppartment();
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    child:
                                        _isLoading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'إضافة الشقة',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _discController.dispose();
    _nameController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
