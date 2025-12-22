import 'package:flutter/material.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/models/apartment_model.dart';
import 'package:flutter_application_8/screens/owner/doneAdd.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants.dart';

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

  // إضافة المتحكمات الجديدة للمحافظة والمدينة
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();

  // قائمة المحافظات (يمكن استبدالها بقائمة حقيقية)
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

  // قائمة المدن (ستتغير بناءً على المحافظة المختارة)
  List<String> _cities = [];
  String? _selectedGovernorate;
  String? _selectedCity;

  String? _apartmentType;
  final List<String> _apartmentTypes = ['شقة', 'استوديو', 'فيلا', 'دوبلكس'];

  // متغيرات للصور
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  // دالة لاختيار الصور
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

  // دالة لحذف صورة
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // أضف هذا المتغير في أعلى State
  List<Apartment> _allApartments =
      []; // يمكن استبدالها بمزود حالة (Provider/Riverpod)

  void _submit() async {
    // التحقق من الحقول الإلزامية
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
      // 1. إنشاء كائن الشقة الجديدة
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

      // 2. حفظ الصور (إذا كنت تريد رفعها للخادم)
      final uploadedImages = await _uploadImages(_selectedImages);

      // 3. تحديث كائن الشقة بالصور المرفوعة (إذا كان لديك روابط URL)
      // final apartmentWithUrls = newApartment.copyWith(images: uploadedImages);

      // 4. حفظ الشقة في القائمة (أو إرسالها للخادم)
      _allApartments.add(newApartment);

      // 5. يمكنك استخدام Provider أو Riverpod لنشر التحديث
      // context.read<ApartmentProvider>().addApartment(newApartment);

      // 6. الانتقال إلى صفحة التأكيد مع تمرير بيانات الشقة
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _isLoading = false);

      // الانتقال إلى صفحة التأكيد مع البيانات
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

  // دالة لرفع الصور (إذا كنت تستخدم خادم)
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];

    // هنا يمكنك رفع الصور للخادم
    // for (var image in images) {
    //   final url = await uploadToServer(File(image.path));
    //   uploadedUrls.add(url);
    // }

    return uploadedUrls;
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  // تصميم خاص لقوائم الاختيار
  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildApartmentTypeChip(String text) {
    final bool isSelected = _apartmentType == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          _apartmentType = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
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

  // ويدجيت لعرض الصور المختارة
  Widget _buildImagesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'الصور المضافة (${_selectedImages.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),

        if (_selectedImages.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
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
    // تحميل المدن بناءً على المحافظة المختارة
    _loadCities();
  }

  void _loadCities() {
    // هنا يمكنك جلب المدن من قاعدة بيانات أو API
    // هذا مثال فقط
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // قسم نوع الشقة
                    Row(
                      children: [
                        Icon(Icons.category, color: accentColor),
                        const SizedBox(width: 8),
                        const Text(
                          'نوع الشقة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              _apartmentTypes
                                  .map((type) => _buildApartmentTypeChip(type))
                                  .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // قسم الصور
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: accentColor),
                        const SizedBox(width: 8),
                        const Text(
                          'صور الشقة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: accentColor, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text(
                        'إضافة صور',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _buildImagesGrid(),

                    const SizedBox(height: 25),

                    // قسم تفاصيل الشقة
                    Row(
                      children: [
                        Icon(Icons.apartment, color: accentColor),
                        const SizedBox(width: 8),
                        const Text(
                          'تفاصيل الشقة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration('اسم الشقة *', Icons.home),
                    ),
                    const SizedBox(height: 16),

                    // حقل المحافظة
                    DropdownButtonFormField<String>(
                      value: _selectedGovernorate,
                      decoration: _dropdownDecoration(
                        'اختر المحافظة *',
                        Icons.location_city,
                      ),
                      items:
                          _governorates.map((governorate) {
                            return DropdownMenuItem(
                              value: governorate,
                              child: Text(governorate),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGovernorate = value;
                          _selectedCity = null;
                          // هنا يمكنك تحديث قائمة المدن بناءً على المحافظة المختارة
                          _loadCities();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى اختيار المحافظة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // حقل المدينة
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: _dropdownDecoration(
                        'اختر المدينة *',
                        Icons.location_on,
                      ),
                      items:
                          _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                      onChanged:
                          _selectedGovernorate == null
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedCity = value;
                                });
                              },
                      validator: (value) {
                        if (_selectedGovernorate != null &&
                            (value == null || value.isEmpty)) {
                          return 'يرجى اختيار المدينة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // الحقول الأصلية
                    TextField(
                      controller: _titleController,
                      decoration: _inputDecoration(
                        'الموقع التفصيلي',
                        Icons.location_pin,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _roomsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'عدد الغرف',
                              Icons.bed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _bathroomsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'عدد الحمامات',
                              Icons.bathtub,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _discController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        'وصف الشقة',
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _areaController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'المساحة ',
                              Icons.square_foot,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'السعر  *',
                              Icons.price_change,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // زر الإضافة
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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

            // مؤشر التحميل
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // التخلص من جميع المتحكمات
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
