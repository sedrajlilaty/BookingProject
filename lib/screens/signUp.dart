import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/AddApartement.dart';
import 'package:flutter_application_8/screens/welcomeScreen2.dart';
import 'package:flutter_application_8/services/signUp-serves.dart'
    show Signupserves;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_8/screens/homePage.dart';
import '../constants.dart';

// ----------------------------------------------------
// 2. شاشة إنشاء حساب (Sign Up Screen)
// ----------------------------------------------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // قيمة اختيار نوع الشخص
  String? _userType;

  // قائمة الخيارات
  final List<String> _userTypes = ['tanent', 'owner'];

  // متحكمات حقول الإدخال
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ملفات الصور
  File? _idImageFile;
  File? _profileImageFile;

  // متغير لتتبع حالة التحميل
  bool _isLoading = false;

  // ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  // تعبيرات منتظمة للتحقق من صحة البيانات
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegExp = RegExp(
    r'^09[0-9]{8}$', // تنسيق رقم سعودي (09XXXXXXXX)
  );

  // دالة مساعدة لإنشاء حقول الإدخال
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    TextEditingController? controller,
    bool readOnly = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: darkTextColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: darkTextColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: const TextStyle(color: darkTextColor),
    );
  }

  // دالة لإنشاء حقل اختيار نوع المستخدم
  Widget _buildUserTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _userType,
        decoration: InputDecoration(
          hintText: 'اختر نوع الحساب',
          hintStyle: TextStyle(color: darkTextColor.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.person_pin,
            color: darkTextColor.withOpacity(0.7),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        items:
            _userTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: darkTextColor),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
        onChanged:
            _isLoading
                ? null
                : (String? newValue) {
                  setState(() {
                    _userType = newValue;
                  });
                },
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: darkTextColor.withOpacity(0.7),
        ),
        isExpanded: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار نوع الحساب';
          }
          return null;
        },
      ),
    );
  }

  // دالة لاختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBackgroundColor,
              onPrimary: accentColor,
              onSurface: darkTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}/${picked.month}/${picked.day}";
      });
    }
  }

  // دالة لاختيار صورة من المعرض
  Future<void> _pickImage(bool isIdImage) async {
    if (_isLoading) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          if (isIdImage) {
            _idImageFile = File(image.path);
          } else {
            _profileImageFile = File(image.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء اختيار الصورة');
    }
  }

  // دالة لالتقاط صورة من الكاميرا
  Future<void> _takePhoto(bool isIdImage) async {
    if (_isLoading) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (photo != null) {
        setState(() {
          if (isIdImage) {
            _idImageFile = File(photo.path);
          } else {
            _profileImageFile = File(photo.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء التقاط الصورة');
    }
  }

  // دالة لعرض رسالة خطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // دالة لعرض خيارات تحميل الصورة
  Future<void> _showImagePickerOptions(bool isIdImage) async {
    if (_isLoading) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: darkTextColor,
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(isIdImage);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: darkTextColor),
                  title: const Text('التقاط صورة'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(isIdImage);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('إلغاء'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة التحقق من صحة البيانات
  String? _validateForm() {
    // التحقق من الاسم الأول
    if (_firstNameController.text.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الأول';
    }

    // التحقق من اسم العائلة
    if (_lastNameController.text.trim().isEmpty) {
      return 'الرجاء إدخال اسم العائلة';
    }

    // التحقق من نوع المستخدم
    if (_userType == null) {
      return 'الرجاء اختيار نوع الحساب';
    }

    // التحقق من رقم الهاتف
    if (_phoneController.text.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (!_phoneRegExp.hasMatch(_phoneController.text.trim())) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 09 ويتكون من 10 أرقام)';
    }

    if (_passwordController.text.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (_passwordController.text.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // التحقق من تأكيد كلمة المرور
    if (_confirmPasswordController.text.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'كلمات المرور غير متطابقة';
    }

    // التحقق من تاريخ الميلاد
    if (_dateController.text.isEmpty) {
      return 'الرجاء اختيار تاريخ الميلاد';
    }

    // التحقق من صورة الهوية (مطلوبة للجميع)
    if (_idImageFile == null) {
      return 'الرجاء تحميل صورة الهوية الوطنية';
    }

    // التحقق من الصورة الشخصية
    if (_profileImageFile == null) {
      return 'الرجاء تحميل صورة شخصية';
    }

    return null; // جميع البيانات صحيحة
  }

  // دالة مساعدة لإنشاء منطقة تحميل الصور
  Widget _buildImageUploadArea(String title, IconData icon, bool isIdImage) {
    final imageFile = isIdImage ? _idImageFile : _profileImageFile;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkTextColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(color: darkTextColor, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 10),
              Icon(icon, color: darkTextColor.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 10),

          if (imageFile != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                setState(() {
                                  if (isIdImage) {
                                    _idImageFile = null;
                                  } else {
                                    _profileImageFile = null;
                                  }
                                });
                              },
                      icon: Icon(
                        Icons.delete,
                        color:
                            _isLoading
                                ? Colors.red.withOpacity(0.5)
                                : Colors.red,
                      ),
                      label: Text(
                        'حذف',
                        style: TextStyle(
                          color:
                              _isLoading
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : () => _showImagePickerOptions(isIdImage),
                      icon: Icon(
                        Icons.edit,
                        color:
                            _isLoading
                                ? buttonColor.withOpacity(0.5)
                                : buttonColor,
                      ),
                      label: Text(
                        'تغيير',
                        style: TextStyle(
                          color:
                              _isLoading
                                  ? buttonColor.withOpacity(0.5)
                                  : buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                OutlinedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : () => _showImagePickerOptions(isIdImage),
                  icon: Icon(
                    Icons.upload_file,
                    color:
                        _isLoading ? buttonColor.withOpacity(0.5) : buttonColor,
                  ),
                  label: Text(
                    'اختر صورة',
                    style: TextStyle(
                      color:
                          _isLoading
                              ? buttonColor.withOpacity(0.5)
                              : buttonColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(
                      color:
                          _isLoading
                              ? buttonColor.withOpacity(0.3)
                              : buttonColor.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: darkTextColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'يُفضل صورة واضحة وبجودة عالية',
                      style: TextStyle(
                        color: darkTextColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final accountType = _userType == 'مؤجر' ? 'owner' : 'tenant';

      final response = await Signupserves.Signup(
        context,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
        _dateController.text,
        accountType,
        _idImageFile!,
        _profileImageFile!,
      );

      if (response != null && response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الحساب بنجاح كـ $_userType'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen2()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إنشاء الحساب'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // دالة لإنشاء زر مع دائرة تحميل
  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSignUp(context),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isLoading ? accentColor.withOpacity(0.7) : accentColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child:
          _isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'جاري التسجيل...',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              )
              : const Text(
                'إنشاء حساب جديد',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // الجزء العلوي مع التاج وعبارة "إنشاء حساب"
                  Container(
                    height: screenHeight * 0.35,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        // زر العودة للخلف - محاذاة لليمين
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pop(context);
                                      },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    _isLoading
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                'العودة لتسجيل الدخول',
                                style: TextStyle(
                                  color:
                                      _isLoading
                                          ? buttonColor.withOpacity(0.5)
                                          : buttonColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.home_work,
                              size: 150,
                              color:
                                  _isLoading
                                      ? accentColor.withOpacity(0.7)
                                      : accentColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  Container(
                    decoration: const BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'أدخل بياناتك',
                          style: TextStyle(
                            color: darkTextColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 30),

                        // الاسم الأول
                        _buildInputField(
                          hintText: 'الاسم الأول',
                          icon: Icons.person,
                          controller: _firstNameController,
                        ),
                        const SizedBox(height: 20),

                        // الاسم الأخير
                        _buildInputField(
                          hintText: 'اسم العائلة',
                          icon: Icons.person_outline,
                          controller: _lastNameController,
                        ),
                        const SizedBox(height: 20),

                        // حقل اختيار نوع المستخدم
                        _buildUserTypeDropdown(),
                        const SizedBox(height: 20),

                        // حقل رقم الهاتف
                        _buildInputField(
                          hintText: 'رقم الهاتف (09XXXXXXXX)',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 20),

                        // حقل كلمة المرور
                        _buildInputField(
                          hintText: 'كلمة المرور (8 أحرف على الأقل)',
                          icon: Icons.lock,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 20),

                        // حقل تأكيد كلمة المرور
                        _buildInputField(
                          hintText: 'تأكيد كلمة المرور',
                          icon: Icons.lock,
                          isPassword: true,
                          controller: _confirmPasswordController,
                        ),
                        const SizedBox(height: 20),

                        // تاريخ الميلاد
                        _buildInputField(
                          controller: _dateController,
                          hintText: 'تاريخ الميلاد (YYYY/MM/DD)',
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _isLoading ? null : () => _selectDate(context),
                        ),
                        const SizedBox(height: 20),

                        // صورة الهوية
                        _buildImageUploadArea(
                          'صورة الهوية الوطنية (أمامية)',
                          Icons.credit_card,
                          true,
                        ),
                        const SizedBox(height: 20),

                        // صورة شخصية
                        _buildImageUploadArea(
                          'صورة شخصية (للملف الشخصي)',
                          Icons.camera_alt,
                          false,
                        ),
                        const SizedBox(height: 30),

                        // زر إنشاء حساب مع دائرة تحميل
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // طبقة تحميل شبه شفافة
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
}
