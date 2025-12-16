import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';

class BookingDone extends StatelessWidget {
  static const String routeName = '/my_bookings';
  const BookingDone({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 100, color: accentColor),
              const SizedBox(height: 50),
              Text(
                'Booking Confirmed!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Your reservation details have been added to your bookings list.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(),
                    ),
                  );
                },
                child: Text(
                  'Go to Home',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cardBackgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
