import 'package:flutter/material.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../owner/homePage.dart' show ApartmentBookingScreen;
import 'myBookingScreen.dart' show MyBookingsScreen;
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

class BookingDone extends StatelessWidget {
  final String bookingId;
  final String apartmentName;
  final String apartmentLocation;
  final double totalPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String paymentMethod;
  final int durationInDays;

  const BookingDone({
    super.key,
    required this.bookingId,
    required this.apartmentName,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
    this.apartmentLocation = '',
    this.paymentMethod = 'Cash',
    this.durationInDays = 1,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : Colors.black;
        Color accent = accentColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Booking Confirmation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: accent,
            centerTitle: true,
            elevation: 4,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, size: 80, color: cardColor),
                ),
                const SizedBox(height: 32),
                Text(
                  'Booking Request Sent - Awaiting Owner Approval',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking ID: $bookingId',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What\'s Next?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accent,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTipItem(
                          Icons.notifications,
                          'You will receive a confirmation via email',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.phone,
                          'The owner will contact you',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.calendar_today,
                          'You can review your bookings anytime',
                          accent,
                          textColor,
                        ),
                        _buildTipItem(
                          Icons.edit,
                          'You can modify the booking within 24 hours',
                          accent,
                          textColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyBookingsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View My Bookings',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ApartmentBookingScreen(isOwner: false),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: accent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Return to Home',
                          style: TextStyle(fontSize: 16, color: accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _shareBookingDetails(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, size: 20, color: accent),
                          const SizedBox(width: 8),
                          Text(
                            'Share Booking Details',
                            style: TextStyle(color: accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipItem(
    IconData icon,
    String text,
    Color accent,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
          ),
        ],
      ),
    );
  }

  void _shareBookingDetails(BuildContext context) {
    final details = '''
Your booking has been successfully confirmed!

Booking ID: $bookingId
Apartment Name: $apartmentName
Check-in Date: ${DateFormat('yyyy-MM-dd').format(checkInDate)}
Check-out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}
Total Amount: \$${totalPrice.toStringAsFixed(2)}

Thank you for using our app!
''';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Booking Details'),
            content: SingleChildScrollView(child: Text(details)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Details copied to clipboard'),
                    ),
                  );
                },
                child: const Text('Copy Details'),
              ),
            ],
          ),
    );
  }
}
