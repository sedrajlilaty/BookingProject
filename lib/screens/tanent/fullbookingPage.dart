import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Theme/theme_cubit.dart';
import '../../Theme/theme_state.dart';

// Note: Ensure that the bookingDone.dart file contains the bool variable isPendingApproval
import 'package:flutter_application_8/screens/tanent/bookingDone.dart';

class FullBookingPage extends StatefulWidget {
  final double pricePerDay;
  final int apartmentId; // Modified to int to resolve type issue
  final String apartmentName;
  final String apartmentImage;
  final String apartmentLocation;

  const FullBookingPage({
    super.key,
    required this.pricePerDay,
    required this.apartmentId,
    required this.apartmentName,
    required this.apartmentImage,
    required this.apartmentLocation,
  });

  @override
  State<FullBookingPage> createState() => _FullBookingPageState();
}

class _FullBookingPageState extends State<FullBookingPage> {
  String selectedDuration = "Week";
  String selectedPayment = "Cash";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  late double pricePerDay;
  double totalPrice = 0;
  int numberOfMonths = 1;

  final durationOptions = [
    "Week",
    "Month",
    "Several Months",
    "15 Days",
    "Year",
  ];
  final paymentMethods = ["Cash", "Credit Card", "E-Wallet"];

  @override
  void initState() {
    super.initState();
    pricePerDay = widget.pricePerDay;
    calculateEndDate();
  }

  void calculateEndDate() {
    switch (selectedDuration) {
      case "Week":
        endDate = startDate.add(const Duration(days: 7));
        totalPrice = pricePerDay * 7;
        break;
      case "Month":
        endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
        totalPrice = pricePerDay * 30;
        break;
      case "Several Months":
        endDate = DateTime(
          startDate.year,
          startDate.month + numberOfMonths,
          startDate.day,
        );
        totalPrice = pricePerDay * 30 * numberOfMonths;
        break;
      case "15 Days":
        endDate = startDate.add(const Duration(days: 15));
        totalPrice = pricePerDay * 15;
        break;
      case "Year":
        endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
        totalPrice = pricePerDay * 365;
        break;
    }
    setState(() {});
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        calculateEndDate();
      });
    }
  }

  Future<void> selectNumberOfMonths(BuildContext context) async {
    final controller = TextEditingController(text: numberOfMonths.toString());
    final months = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select Number of Months"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Number of Months",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = int.tryParse(controller.text) ?? 1;
                  Navigator.pop(context, value);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (months != null && months > 0) {
      setState(() {
        numberOfMonths = months;
        selectedDuration = "Several Months";
        calculateEndDate();
      });
    }
  }

  // 1. Added async to the function to be able to use await
  Future<void> _addBooking(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // Ensure login
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must log in first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authProvider.user!;
    final now = DateTime.now();
    final durationInDays = endDate.difference(startDate).inDays;

    // Create local booking ID for display only
    final String bookingId =
        'B${now.millisecondsSinceEpoch}${_getUserPrefix(user.id.toString())}';

    // 2. Prepare the data required for the server accurately
    final Map<String, dynamic> newBooking = {
      'apartment_id': widget.apartmentId, // Send ID as int
      'start_date':
          startDate.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'end_date': endDate.toIso8601String().split('T')[0],
    };

    debugPrint("Token being sent: ${authProvider.token}");

    // 3. Execute booking and await result (Success or Failure)
    bool success = await bookingProvider.createBookingOnServer(
      newBooking,
      authProvider.token!,
    );

    if (success) {
      // 4. Only in case of success, navigate to the success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BookingDone(
                bookingId: bookingId,
                apartmentName: widget.apartmentName,
                apartmentLocation: widget.apartmentLocation,
                totalPrice: totalPrice,
                checkInDate: startDate,
                checkOutDate: endDate,
                paymentMethod: selectedPayment,
                durationInDays: durationInDays,
              ),
        ),
      );
    } else {
      // 5. In case of failure (e.g., error 409 - apartment already booked)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sorry, these dates are already booked for this apartment. Please choose another date.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      // User stays on the current page to modify the date
    }
  }

  String _getUserPrefix(String userId) {
    if (userId.isEmpty) return 'USR';
    return userId.length > 3 ? userId.substring(0, 3) : userId;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;
        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color accent = accentColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Booking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: accent,
            centerTitle: true,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Apartment information card
                  Card(
                    color: cardColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              widget.apartmentName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Daily Price: \$${pricePerDay.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Booking Duration"),
                  _buildDropdown(
                    durationOptions,
                    selectedDuration,
                    (String? newValue) async {
                      if (newValue == "Several Months") {
                        await selectNumberOfMonths(context);
                      }
                      setState(() {
                        selectedDuration = newValue!;
                        calculateEndDate();
                      });
                    },
                    cardColor,
                    textColor,
                    accent,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Booking Start Date"),
                  _buildDateTile(
                    dateFormat.format(startDate),
                    Icons.calendar_today,
                    () => selectStartDate(context),
                    cardColor,
                    textColor,
                    accent,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Booking End Date (Automatic)"),
                  _buildDateTile(
                    dateFormat.format(endDate),
                    Icons.event_available,
                    null,
                    cardColor,
                    textColor,
                    accent,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Payment Method"),
                  _buildDropdown(
                    paymentMethods,
                    selectedPayment,
                    (String? newValue) {
                      setState(() => selectedPayment = newValue!);
                    },
                    cardColor,
                    textColor,
                    accent,
                  ),

                  const SizedBox(height: 25),

                  // Price summary
                  Card(
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const Divider(),
                          _buildPriceRow(
                            "Stay Duration",
                            "${endDate.difference(startDate).inDays} days",
                            textColor,
                          ),
                          _buildPriceRow(
                            "Total",
                            "\$${totalPrice.toStringAsFixed(2)}",
                            accent,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Pending approval notice
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Note: Your request will be sent to the owner for approval before final booking confirmation.",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark
                                      ? Colors.orange[200]
                                      : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _addBooking(context),
                      child: const Text(
                        'Send Booking Request to Owner',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widgets to reduce code duplication
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
    Color cardColor,
    Color textColor,
    Color accent,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: cardColor.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: TextStyle(color: textColor),
      items:
          items.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateTile(
    String text,
    IconData icon,
    VoidCallback? onTap,
    Color cardColor,
    Color textColor,
    Color accent,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.15),
          border: Border.all(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(color: textColor)),
            Icon(icon, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
