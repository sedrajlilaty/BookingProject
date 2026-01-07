import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/constants.dart';
import 'package:flutter_application_8/providers/booking_provider.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:flutter_application_8/models/booking_model.dart';

class BookingRequest extends StatefulWidget {
  const BookingRequest({super.key});

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  @override
  void initState() {
    super.initState();
    // Fetch owner requests when opening the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        Provider.of<BookingProvider>(
          context,
          listen: false,
        ).fetchOwnerBookings(auth.token!);
      }
    });
  }

  // Unified function to handle owner decisions (approve/reject) for both booking and modification
  Future<void> handleAction(dynamic bookingId, String action) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    await bookingProvider.handleBookingAction(bookingId, action, auth.token!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'approve'
              ? 'Operation completed successfully'
              : 'Request rejected',
        ),
        backgroundColor: action == 'approve' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Filter list to include new booking requests (pending) and modification requests (pendingUpdate)
    final allRequests =
        bookingProvider.bookings
            .where(
              (b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.pendingUpdate,
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Booking and Modification Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          bookingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : allRequests.isEmpty
              ? const Center(child: Text("No pending requests at the moment"))
              : RefreshIndicator(
                onRefresh: () async {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await bookingProvider.fetchOwnerBookings(auth.token!);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: allRequests.length,
                  itemBuilder: (context, index) {
                    final item = allRequests[index];
                    return _buildRequestCard(item);
                  },
                ),
              ),
    );
  }

  Widget _buildRequestCard(Booking item) {
    // Check if the request is a modification request
    bool isUpdateReq = item.status == BookingStatus.pendingUpdate;

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Request #: #${item.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _statusBadge(isUpdateReq),
              ],
            ),

            // Additional alert if the request is "modification"
            if (isUpdateReq)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Tenant requests date modification",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 25),
            Text(
              "Apartment Name: ${item.apartmentName}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              "Requested Dates: ${item.startDate.day}/${item.startDate.month} to ${item.endDate.day}/${item.endDate.month}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              "Updated Total Price: ${item.totalPrice} SAR",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 15),

            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => handleAction(item.id, 'approve'),
                    icon: const Icon(Icons.check),
                    label: Text(
                      isUpdateReq ? "Approve Modification" : "Approve Booking",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed:
                        () => handleAction(
                          item.id,
                          'reject',
                        ), // Ensure spelling matches server 'cancel'
                    icon: const Icon(Icons.close),
                    label: Text(
                      isUpdateReq ? "Reject Modification" : "Reject Booking",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isUpdate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isUpdate ? Colors.deepOrange : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isUpdate ? "New Modification" : "New Request",
        style: TextStyle(
          color: isUpdate ? Colors.deepOrange : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
