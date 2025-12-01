import 'package:flutter/material.dart';
import 'package:flutter_application_8/logIn.dart';
import 'package:flutter_application_8/signUp.dart';
import 'package:flutter_application_8/welcomeScreen2.dart';
import 'constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceAround, // لتوزيع العناصر بين الأعلى والأسفل
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // المساحة العلوية - عبارة Welcome في المنتصف
            Expanded(
              child: Center(
                child: Text(
                  'Welcome !',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // المساحة السفلية - زر Get Started
            Column(
              children: [
                _buildOutlineButton(
                  text: 'Continue ->',
                  textColor: accentColor,
                  borderColor: accentColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen2(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50), // مسافة إضافية من الأسفل
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18, color: textColor)),
      ),
    );
  }
}
