import 'package:flutter/material.dart';
import 'package:flutter_application_8/homePage.dart';

import 'constants.dart';

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
  final List<String> _userTypes = ['مستأجر', 'مؤجر'];

  // متحكمات حقول الإدخال
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // متغير لتتبع حالة التحميل
  bool _isLoading = false;

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
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 05 ويتكون من 10 أرقام)';
    }

    // التحقق من البريد الإلكتروني
    if (_emailController.text.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!_emailRegExp.hasMatch(_emailController.text.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }

    // التحقق من كلمة المرور
    if (_passwordController.text.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (_passwordController.text.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
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

    return null; // جميع البيانات صحيحة
  }

  // دالة مساعدة لإنشاء منطقة تحميل الصور
  Widget _buildImageUploadArea(String title, IconData icon) {
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
          OutlinedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      // TODO: إضافة منطق تحميل الصورة
                    },
            icon: Icon(
              Icons.upload_file,
              color: _isLoading ? buttonColor.withOpacity(0.5) : buttonColor,
            ),
            label: Text(
              'اختر ملف',
              style: TextStyle(
                color: _isLoading ? buttonColor.withOpacity(0.5) : buttonColor,
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
        ],
      ),
    );
  }

  // دالة معالجة إنشاء الحساب
  Future<void> _handleSignUp(BuildContext context) async {
    // إغلاق لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // التحقق من صحة البيانات
    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // بدء التحميل
    setState(() {
      _isLoading = true;
    });

    try {
      // عرض رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التسجيل بنجاح كـ $_userType'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // محاكاة عملية تسجيل (يمكن استبدالها بالاتصال بالخادم)
      await Future.delayed(const Duration(seconds: 2));

      // الانتقال إلى الشاشة المناسبة
      if (_userType == 'مؤجر') {
        // الانتقال إلى صفحة إضافة الشقة للمؤجر
        /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddApartmentScreen(userType: _userType!),
          ),
        );*/
      } else if (_userType == 'مستأجر') {
        // الانتقال إلى الصفحة الرئيسية للمستأجر
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ApartmentBookingScreen()),
        );
      }
    } catch (e) {
      // في حالة حدوث خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('حدث خطأ أثناء التسجيل'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // إيقاف التحميل
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                  Text(
                    'جاري التسجيل...',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
                        // أيقونة المنزل - محاذاة لليمين
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
                  // البطاقة السفلية (Sign Up Form)
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
                          hintText: 'رقم الهاتف (05XXXXXXXX)',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 20),

                        // حقل البريد الإلكتروني

                        // حقل كلمة المرور
                        _buildInputField(
                          hintText: 'كلمة المرور (6 أحرف على الأقل)',
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
                        ),
                        const SizedBox(height: 20),

                        // صورة شخصية
                        _buildImageUploadArea(
                          'صورة شخصية (للملف الشخصي)',
                          Icons.camera_alt,
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
