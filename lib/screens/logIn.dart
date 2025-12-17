import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/AddApartement.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/screens/signUp.dart';
import 'package:flutter_application_8/services/logIn_serves.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _userType;
  final List<String> _userTypes = ['tenant', 'owner'];
  bool _isLoading = false;
  static final RegExp _phoneRegExp = RegExp(r'^09[0-9]{8}$');

  // دالة للتحقق من صحة البيانات
  String? _validateForm() {
    if (_phoneController.text.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (!_phoneRegExp.hasMatch(_phoneController.text.trim())) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 05 ويتكون من 10 أرقام)';
    }

    if (_passwordController.text.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (_passwordController.text.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (_userType == null) {
      return 'الرجاء اختيار نوع الحساب';
    }

    return null;
  }

  Future<void> _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

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

    setState(() {
      _isLoading = true;
    });

    // استدعاء خدمة تسجيل الدخول بدلاً من Future.delayed
    final response = await LoginServes.logIn(
      context,
      _phoneController.text, // تأكد من وجود هذا المتحكم
      _passwordController.text, // تأكد من وجود هذا المتحكم
      _userType!, // تحويل نوع المستخدم إذا لزم الأمر
    );

    if (response != null && response.statusCode == 201) {
      // تسجيل الدخول ناجح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تسجيل الدخول بنجاح كـ $_userType'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // حفظ بيانات المستخدم إذا كنت تستخدم state management
      // على سبيل المثال:
      // await _saveUserData(response.data);

      if (_userType == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddApartmentScreen()),
        );
      } else if (_userType == 'tenant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()),
        );
      }
    }
    {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: !_isLoading,
      textAlign: TextAlign.right,
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: TextStyle(
        color: darkTextColor,
        decoration: _isLoading ? TextDecoration.none : null,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleLogin(context),
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
                    'جاري تسجيل الدخول...',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              )
              : const Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: Stack(
          children: [
            // الهيكل الرئيسي مع التمرير
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                  minWidth: screenWidth,
                ),
                child: Column(
                  children: [
                    // الجزء العلوي مع التاج
                    // الجزء العلوي مع التاج
                    Container(
                      height: screenHeight * 0.35,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 40,
                      ),
                      alignment: Alignment.bottomRight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // بداية التدرج
                            Color(0xFFF1F3F5),
                            Color(0xFF005F73),
                            Color(0xFF005F73), // نهاية التدرج
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Icon(
                            Icons.home_work,
                            size: 150,
                            color:
                                Colors.white, // تغيير لون الأيقونة إلى الأبيض
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // البطاقة السفلية (Login Form) - تم تغييرها لتصبح مرنة
                    Container(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.65, // ارتفاع أدنى مناسب
                      ),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              color: darkTextColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 30),

                          // حقل اختيار نوع المستخدم
                          _buildUserTypeDropdown(),
                          const SizedBox(height: 20),

                          // حقل رقم الهاتف
                          _buildInputField(
                            hintText: 'رقم الهاتف (09XXXXXXXX)',
                            icon: Icons.phone,
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
                          const SizedBox(height: 10),

                          // زر "نسيت كلمة المرور؟"
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        print('Forgot Password?');
                                        // TODO: إضافة منطق استعادة كلمة المرور
                                      },
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color:
                                      _isLoading
                                          ? darkTextColor.withOpacity(0.3)
                                          : darkTextColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // زر تسجيل الدخول مع دائرة تحميل
                          _buildLoginButton(context),
                          const SizedBox(height: 25),

                          // رابط "ليس لديك حساب؟"
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ليس لديك حساب؟',
                                  style: TextStyle(
                                    color:
                                        _isLoading
                                            ? darkTextColor.withOpacity(0.3)
                                            : darkTextColor.withOpacity(0.7),
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const SignUpScreen(),
                                              ),
                                            );
                                          },
                                  child: Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? accentColor.withOpacity(0.5)
                                              : accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // طبقة تحميل شاملة
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
