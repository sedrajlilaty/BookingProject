import 'package:flutter/material.dart';
import 'package:flutter_application_8/screens/logIn.dart';
import 'package:flutter_application_8/screens/signUp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants.dart';
import '../Theme/theme_cubit.dart';
import '../Theme/theme_state.dart';

class WelcomeScreen2 extends StatefulWidget {
  const WelcomeScreen2({super.key});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<WelcomeCardData> _welcomeCards = [
    WelcomeCardData(
      title: 'أهلاً بك في تطبيق عقار',
      subtitle: 'منصة متكاملة لتأجير واستئجار الشقق السكنية',
      icon: Icons.apartment,
    ),
    WelcomeCardData(
      title: 'ابحث عن شقتك المثالية',
      subtitle: 'آلاف الشقق المتاحة في مختلف المناطق',
      icon: Icons.search,
    ),
    WelcomeCardData(
      title: 'حجز آمن وسهل',
      subtitle: 'عملية حجز موثوقة مع دفع إلكتروني آمن',
      icon: Icons.security,
    ),
    WelcomeCardData(
      title: 'إدارة ممتلكاتك',
      subtitle: 'لأصحاب الشقق: قدم عرضك وأدر حجوزاتك',
      icon: Icons.manage_accounts,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentPage < _welcomeCards.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(0);
      }
      _startAutoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state is DarkState;

        // ألوان حسب الثيم
        final backgroundColor = isDarkMode ? Colors.grey[900]! : primaryBackgroundColor;
        final cardColor = isDarkMode ? Colors.grey[800]! : cardBackgroundColor;
        final textColor = isDarkMode ? Colors.white : darkTextColor;
        final secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
        final buttonTextColor = Colors.white;
        final iconColor = accentColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // أيقونة التطبيق
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(Icons.home_work, size: 120, color: accentColor),
                  ),
                ),
                const SizedBox(height: 30),
                // PageView الترحيبي
                Expanded(
                  flex: 2,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _welcomeCards.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      final card = _welcomeCards[index];
                      return WelcomeCard(
                        title: card.title,
                        subtitle: card.subtitle,
                        icon: card.icon,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                      );
                    },
                  ),
                ),
                // مؤشر الصفحات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _welcomeCards.length,
                        (index) => _buildPageIndicator(index == _currentPage, iconColor),
                  ),
                ),
                const SizedBox(height: 40),
                // زر تسجيل الدخول
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // زر إنشاء حساب جديد
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class WelcomeCardData {
  final String title;
  final String subtitle;
  final IconData icon;

  WelcomeCardData({required this.title, required this.subtitle, required this.icon});
}

class WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color iconColor;

  const WelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardColor,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: iconColor),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 15),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: secondaryTextColor, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
