import 'package:flutter/material.dart';
import 'package:flutter_application_8/logIn.dart';
import 'package:flutter_application_8/signUp.dart';
import 'constants.dart';

class WelcomeScreen2 extends StatefulWidget {
  const WelcomeScreen2({super.key});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<WelcomeCard> _welcomeCards = [
    WelcomeCard(
      title: 'أهلاً بك في تطبيق عقار',
      subtitle: 'منصة متكاملة لتأجير واستئجار الشقق السكنية',
      icon: Icons.apartment,
    ),
    WelcomeCard(
      title: 'ابحث عن شقتك المثالية',
      subtitle: 'آلاف الشقق المتاحة في مختلف المناطق',
      icon: Icons.search,
    ),
    WelcomeCard(
      title: 'حجز آمن وسهل',
      subtitle: 'عملية حجز موثوقة مع دفع إلكتروني آمن',
      icon: Icons.security,
    ),
    WelcomeCard(
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
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // اللوجو في الأعلى
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Icon(
                Icons.house_rounded, // أو Icons.home
                size: 120,
                color: accentColor, // لون ذهبي #DDA15E
              ),
            ),

            const SizedBox(height: 30),

            // العبارات الترحيبية ضمن PageView
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
                  return _welcomeCards[index];
                },
              ),
            ),

            // مؤشر الصفحات
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _welcomeCards.length,
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 40),

            // زر تسجيل الدخول في الأسفل
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // زر إنشاء حساب جديد
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: accentColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? buttonColor : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const WelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
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
              Icon(icon, size: 60, color: buttonColor),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
