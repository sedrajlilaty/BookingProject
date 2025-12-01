import 'package:flutter/material.dart';
import 'package:flutter_application_8/homePage.dart';
import 'package:flutter_application_8/signUp.dart';
import 'constants.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryBackgroundColor,
        hintColor: accentColor,
        fontFamily:
            'Cairo', // مثال على خط عربي، تأكد من إضافته إلى pubspec.yaml
      ),
      home: const LoginScreen(), // ابدأ بشاشة تسجيل الدخول
    );
  }
}
*/
// ----------------------------------------------------
// 1. شاشة تسجيل الدخول (Login Screen)
// ----------------------------------------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الجزء العلوي مع التاج وعبارة "مرحباً"
            Container(
              height: screenHeight * 0.4, // 40% من ارتفاع الشاشة
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              alignment:
                  Alignment.bottomRight, // محاذاة النص والتاج لليمين والأسفل
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.house_rounded, // أو Icons.home
                    size: 140,
                    color: accentColor, // لون ذهبي #DDA15E
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'أهلاً بك أيها المستأجر', // Welcome Tenant
                    style: TextStyle(color: buttonColor, fontSize: 18),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            // البطاقة السفلية (Login Form)
            Container(
              height: screenHeight * 0.6, // 60% من ارتفاع الشاشة
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
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: darkTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 30),

                  // حقل البريد الإلكتروني
                  _buildInputField(hintText: 'رقم الهاتف', icon: Icons.phone),
                  const SizedBox(height: 20),

                  // حقل كلمة المرور
                  _buildInputField(
                    hintText: 'كلمة المرور',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),

                  // زر "نسيت كلمة المرور؟"
                  Align(
                    alignment:
                        Alignment.centerLeft, // محاذاة لليسار لسهولة الضغط
                    child: TextButton(
                      onPressed: () {
                        print('Forgot Password?');
                      },
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: darkTextColor.withOpacity(0.7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر تسجيل الدخول
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApartmentBookingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor, // لون الزر أغمق
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // رابط "ليس لديك حساب؟" للانتقال إلى شاشة التسجيل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(color: darkTextColor.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // أقسام تسجيل الدخول عبر وسائل التواصل الاجتماعي (اختياري)
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'أو سجل الدخول باستخدام',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(color: darkTextColor),
                  // ),
                  // const SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _buildSocialButton('assets/images/google.png'), // أضف صور الأيقونات
                  //     SizedBox(width: 20),
                  //     _buildSocialButton('assets/images/facebook.png'),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء حقول الإدخال
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      textAlign: TextAlign.right, // محاذاة النص المدخل لليمين
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: darkTextColor.withOpacity(0.5)),
        prefixIcon: Icon(
          icon,
          color: darkTextColor.withOpacity(0.7),
        ), // الأيقونة على اليسار
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
      ),
      style: const TextStyle(color: darkTextColor), // لون النص المكتوب
    );
  }

  // دالة مساعدة لأزرار التواصل الاجتماعي (إذا أردت استخدامها)
  // Widget _buildSocialButton(String imagePath) {
  //   return Container(
  //     width: 50,
  //     height: 50,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.2),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Center(
  //       child: Image.asset(imagePath, height: 30),
  //     ),
  //   );
  // }
}
