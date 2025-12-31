import 'package:flutter/material.dart';
import 'package:flutter_application_8/network/urls.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_8/screens/owner/AddApartement.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/screens/signUp.dart';
import 'package:flutter_application_8/services/logIn_serves.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String? _validateForm() {
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

    if (_userType == null) {
      return 'الرجاء اختيار نوع الحساب';
    }

    return null;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kToken, token);
    await prefs.setBool(kIsLoggedIn, true);
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setLoading(true);

    try {
      print('📞 جاري تسجيل الدخول...');
      print('📱 رقم الهاتف: ${_phoneController.text}');
      print('🔑 نوع الحساب: $_userType');

      // استدعاء خدمة تسجيل الدخول
      final response = await LoginServes.logIn(
        context,
        _phoneController.text,
        _passwordController.text,
        _userType!,
      );

      print('📥 استجابة الخادم: ${response?.data}');
      print('📊 نوع الاستجابة: ${response?.runtimeType}');

      // ⚠️ **التحقق من أن response ليست null**
      if (response == null) {
        throw Exception('فشل الاتصال بالخادم');
      }

      // ⚠️ **التصحيح: response هو كائن Response، البيانات في response.data**
      final data = response.data as Map<String, dynamic>;
      print('✅ البيانات المستلمة: $data');

      // استخرج البيانات
      final message = data['message'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      final token = data['token'] as String?;

      if (message != null) print('📝 الرسالة: $message');
      if (userData != null) print('👤 المستخدم: ${userData['name']}');
      if (token != null) print('🔐 التوكن: ${token.substring(0, 20)}...');

      // ⚠️ **التحقق من البيانات الأساسية**
      if (userData == null) {
        print('❌ userData is null');
        throw Exception('لا توجد بيانات مستخدم في الاستجابة');
      }

      if (token == null || token.isEmpty) {
        print('❌ token is null or empty');
        throw Exception('لا يوجد رمز مصادقة في الاستجابة');
      }

      // ⚠️ **بناء URL للصور**
      String baseUrl = Urls.baseUrl; // نفس الـ baseUrl في LoginServes
      String? profileImageUrl;
      String? idImageUrl;

      if (userData['personal_image'] != null) {
        profileImageUrl = '$baseUrl/storage/${userData['personal_image']}';
        print('🖼️ رابط الصورة الشخصية: $profileImageUrl');
      } else {
        print('⚠️ لا توجد صورة شخصية في الاستجابة');
      }

      if (userData['national_id_image'] != null) {
        idImageUrl = '$baseUrl/storage/${userData['national_id_image']}';
        print('🆔 رابط صورة الهوية: $idImageUrl');
      } else {
        print('⚠️ لا توجد صورة هوية في الاستجابة');
      }

      // ⚠️ **استخراج البيانات بأسماء الحقول الصحيحة**
      await authProvider.login(
        userId: userData['id']?.toString() ?? '0',
        firstName: userData['name']?.toString() ?? '',
        lastName: userData['last_name']?.toString() ?? '',
        phone: userData['phone']?.toString() ?? _phoneController.text,
        email:
            userData['email']?.toString() ??
            '${userData['phone'] ?? _phoneController.text}@temp.com',
        userType: userData['account_type']?.toString() ?? _userType!,
        birthDate: userData['birthdate']?.toString() ?? '',
        profileImageUrl: profileImageUrl,
        idImageUrl: idImageUrl,
        token: token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'تم تسجيل الدخول بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // التنقل بناءً على نوع المستخدم
      final accountType = userData['account_type']?.toString() ?? _userType!;
      print('🎯 نوع الحساب للتنقل: $accountType');
      if (response != null && response.statusCode == 200) {
        saveToken(response.data['data']['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MainNavigationScreen(isOwner: accountType == 'owner'),
          ),
        );
      }
    } on FormatException catch (e) {
      print('❌ خطأ في تنسيق البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تنسيق البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception catch (e) {
      print('❌ خطأ عام: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تسجيل الدخول: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('❌ خطأ غير متوقع: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      authProvider.setLoading(false);
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
                  value == 'owner' ? 'owner' : 'tenant',
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
    final authProvider = Provider.of<AuthProvider>(context);
    _isLoading = authProvider.isLoading;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                  minWidth: screenWidth,
                ),
                child: Column(
                  children: [
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
                            Color(0xFFF1F3F5),
                            Color(0xFF005F73),
                            Color(0xFF005F73),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Icon(Icons.home_work, size: 150, color: Colors.white),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.65,
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
                          _buildUserTypeDropdown(),
                          const SizedBox(height: 20),
                          _buildInputField(
                            hintText: 'رقم الهاتف (09XXXXXXXX)',
                            icon: Icons.phone,
                            controller: _phoneController,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            hintText: 'كلمة المرور (8 أحرف على الأقل)',
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        print('Forgot Password?');
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
                          _buildLoginButton(context),
                          const SizedBox(height: 25),
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
