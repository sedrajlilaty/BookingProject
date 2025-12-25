import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/screens/owner/AddApartement.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/screens/signUp.dart';
import 'package:flutter_application_8/services/logIn_serves.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants.dart';
import '../Theme/theme_cubit.dart';
import '../Theme/theme_state.dart';

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
    if (_phoneController.text.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
    if (!_phoneRegExp.hasMatch(_phoneController.text.trim())) return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 09 ويتكون من 10 أرقام)';
    if (_passwordController.text.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (_passwordController.text.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (_userType == null) return 'الرجاء اختيار نوع الحساب';
    return null;
  }

  Future<void> _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setLoading(true);

    try {
      final response = await LoginServes.logIn(context, _phoneController.text, _passwordController.text, _userType!);
      if (response == null) throw Exception('فشل الاتصال بالخادم');

      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as String?;
      final userData = data['User'] as Map<String, dynamic>?;
      final token = data['Token'] as String?;

      if (userData == null) throw Exception('لا توجد بيانات مستخدم في الاستجابة');
      if (token == null || token.isEmpty) throw Exception('لا يوجد رمز مصادقة في الاستجابة');

      String baseUrl = 'http://192.168.137.101:8000';
      String? profileImageUrl = userData['personal_image'] != null ? '$baseUrl/storage/${userData['personal_image']}' : null;
      String? idImageUrl = userData['national_id_image'] != null ? '$baseUrl/storage/${userData['national_id_image']}' : null;

      await authProvider.login(
        userId: userData['id']?.toString() ?? '0',
        firstName: userData['name']?.toString() ?? '',
        lastName: userData['last_name']?.toString() ?? '',
        phone: userData['phone']?.toString() ?? _phoneController.text,
        email: userData['email']?.toString() ?? '${userData['phone'] ?? _phoneController.text}@temp.com',
        userType: userData['account_type']?.toString() ?? _userType!,
        birthDate: userData['birthdate']?.toString() ?? '',
        profileImageUrl: profileImageUrl,
        idImageUrl: idImageUrl,
        token: token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'تم تسجيل الدخول بنجاح'), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
      );

      final accountType = userData['account_type']?.toString() ?? _userType!;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen(isOwner: accountType == 'owner')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تسجيل الدخول: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      authProvider.setLoading(false);
    }
  }

  Widget _buildUserTypeDropdown(Color textColor, Color fillColor) {
    return Container(
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<String>(
        value: _userType,
        decoration: InputDecoration(
          hintText: 'اختر نوع الحساب',
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.person_pin, color: textColor.withOpacity(0.7)),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        items: _userTypes.map((value) => DropdownMenuItem(value: value, child: Text(value == 'owner' ? 'مالك' : 'مستأجر', style: TextStyle(color: textColor), textAlign: TextAlign.right))).toList(),
        onChanged: _isLoading ? null : (val) => setState(() => _userType = val),
        dropdownColor: fillColor,
        icon: Icon(Icons.arrow_drop_down, color: textColor.withOpacity(0.7)),
        isExpanded: true,
      ),
    );
  }

  Widget _buildInputField({required String hintText, required IconData icon, bool isPassword = false, TextEditingController? controller, required Color textColor, required Color fillColor, required Color iconColor}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: !_isLoading,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildLoginButton(Color accentColor) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleLogin(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLoading ? accentColor.withOpacity(0.7) : accentColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: _isLoading
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
        SizedBox(width: 10),
        Text('جاري تسجيل الدخول...', style: TextStyle(fontSize: 18, color: Colors.white)),
      ])
          : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    _isLoading = authProvider.isLoading;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is DarkState;
        final backgroundColor = isDark ? Colors.grey[900]! : primaryBackgroundColor;
        final cardColor = isDark ? Colors.grey[800]! : Colors.white;
        final textColor = isDark ? Colors.white : darkTextColor;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight, minWidth: screenWidth),
                    child: Column(
                      children: [
                        Container(
                          height: screenHeight * 0.35,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                          alignment: Alignment.bottomRight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [Colors.grey[850]!, Colors.grey[850]!]
                                  : [Color(0xFFF1F3F5), Color(0xFF005F73)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [Icon(Icons.home_work, size: 150, color: Colors.white), const SizedBox(height: 10)],
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(minHeight: screenHeight * 0.65),
                          decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('تسجيل الدخول', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                              const SizedBox(height: 30),
                              _buildUserTypeDropdown(textColor, cardColor),
                              const SizedBox(height: 20),
                              _buildInputField(hintText: 'رقم الهاتف (09XXXXXXXX)', icon: Icons.phone, controller: _phoneController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                              const SizedBox(height: 20),
                              _buildInputField(hintText: 'كلمة المرور (8 أحرف على الأقل)', icon: Icons.lock, isPassword: true, controller: _passwordController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: _isLoading ? null : () => print('Forgot Password?'),
                                  child: Text('نسيت كلمة المرور؟', style: TextStyle(color: textColor.withOpacity(0.7))),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildLoginButton(accentColor),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('ليس لديك حساب؟', style: TextStyle(color: textColor.withOpacity(0.7))),
                                  TextButton(
                                    onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                                    child: Text('إنشاء حساب', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                                  ),
                                ],
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
                    child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
