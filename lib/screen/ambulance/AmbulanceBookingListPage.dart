import 'package:flutter/material.dart';
import 'package:hm_ambulance_app/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_code/custom_text_style.dart';
import '../../provider/AuthProvider.dart';
import '../../provider/AmbulanceProvider.dart';
import '../../route_constants.dart';
import '../auth/StudentModel.dart';
import 'AmbulanceBookingModel.dart';

class AmbulanceBookingList extends StatefulWidget {
  const AmbulanceBookingList({super.key});

  @override
  _AmbulanceBookingListState createState() => _AmbulanceBookingListState();
}

class _AmbulanceBookingListState extends State<AmbulanceBookingList> {
  late Future<void> _driverData;
  String driverId = '';
  String? driverStatus = '';
  String? driverName = '';

  @override
  void initState() {
    super.initState();
    _driverData = getUserDataFromPreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AmbulanceBookingProvider>(context, listen: false)
          .fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ambulanceProvider = Provider.of<AmbulanceBookingProvider>(context);
    final authProvider = Provider.of<AuthProviderr>(context, listen: false);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/images/logo_ti.png', height: 40),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  children: [
                    Text(
                      driverStatus ?? "Offline",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Switch(
                      value: driverStatus == 'Online' ? true : false,
                      // Replace with actual online/offline status
                      onChanged: (value) async {
                        String newStatus = value ? "Online" : "Offline";

                        // Update Firestore status via the AuthProvider
                        await authProvider.updateDriverStatus(
                            driverId, newStatus);

                        // Update SharedPreferences
                        await updateDriverStatus(newStatus);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, profileScreenRoute);
                },
                icon: const Icon(Icons.person),
              ),
            ],
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BookingListView(
                status: 'Pending',
                driverName: driverName,
                driverId: driverId,
                driver_Status: driverStatus,
                bookings: ambulanceProvider.pendingBooking,
                // Replace with your pending bookings list
                provider:
                    ambulanceProvider, // Replace with your pending bookings list
              ),
              BookingListView(
                status: 'Accepted',
                driverId: driverId,
                driver_Status: driverStatus,
                provider: ambulanceProvider,
                bookings: ambulanceProvider
                    .acceptedBooking, // Replace with your accepted bookings list
              ),
              BookingListView(
                status: 'Completed',
                driverId: driverId,
                driver_Status: driverStatus,
                provider: ambulanceProvider,
                bookings: ambulanceProvider
                    .completedBooking, // Replace with your completed bookings list
              ),
            ],
          ),
        )
        /*       body: ambulanceProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Trigger data fetching when the user swipes down
                    await Provider.of<AmbulanceBookingProvider>(context,
                            listen: false)
                        .fetchBookings();
                  },
                  child: driverStatus == 'Offline'
                      ? Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            "You are Offline.\nPlease go online to see your bookings",
                            style: CustomTextStyles.titleLarge,
                          ),
                        )
                      : ambulanceProvider.bookings.isEmpty
                          ? Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                "No bookings available",
                                style: CustomTextStyles.titleLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: ambulanceProvider.bookings.length,
                              itemBuilder: (context, index) {
                                final booking = ambulanceProvider.bookings[index];
                                return BookingCard(
                                  booking: booking,
                                  onCancel: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'Cancel Booking',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        content: Text(
                                          'Are you sure you want to cancel this booking?',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: Text(
                                              'No',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text(
                                              'Yes',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      ambulanceProvider
                                          .deleteBooking(booking.bookingId);
                                    }
                                  },
                                  onAccept: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'Accept Booking',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        content: Text(
                                          'Are you sure you want to accept this booking?',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(
                                              'No',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              await ambulanceProvider
                                                  .acceptBooking(
                                                      booking.bookingId,
                                                      driverId,
                                                      context);
                                              booking.confirmStatus = 'Accepted';
                                              flushBarSuccessMsg(
                                                  context,
                                                  'Success',
                                                  'Booking accepted successfully!');
                                            },
                                            child: Text(
                                              'Yes',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onCompleted: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'Complete Booking?',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        content: Text(
                                          'Have you Completed this Booking?',
                                          style: CustomTextStyles.titleMedium,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(
                                              'No',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              await ambulanceProvider
                                                  .completeBooking(
                                                      booking.bookingId,
                                                      driverId,
                                                      context);
                                              booking.confirmStatus = 'Completed';

                                              flushBarSuccessMsg(
                                                  context,
                                                  'Completed!1',
                                                  'Booking Completed successfully!');
                                            },
                                            child: Text(
                                              'Yes',
                                              style: CustomTextStyles.titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      // ambulanceProvider.acceptBooking(booking.bookingId);
                                    }
                                  },
                                );
                              },
                            ),
                )),*/
        );
  }

  Future<void> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    driverId = prefs.getString('driverId') ?? '';
    driverStatus = prefs.getString('status') ?? 'Offline';
    driverName = prefs.getString('name') ?? '';
    setState(() {}); // Update the UI with the loaded values
  }

  Future<void> updateDriverStatus(String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', newStatus);
    driverStatus = newStatus;
    setState(() {}); // Update the UI with the new status
  }
}

class BookingListView extends StatelessWidget {
  final String status;
  final String? driver_Status;
  final String? driverId;
  final String? driverName;
  final AmbulanceBookingProvider provider;
  final List<AmbulanceModel>
      bookings; // Replace `dynamic` with your booking model

  const BookingListView({
    Key? key,
    required this.status,
    required this.driverId,
     this.driverName,
    required this.bookings,
    required this.provider,
    required this.driver_Status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return driver_Status == 'Offline'
        ? Center(
            child: Text(
              'You are Offline.\n Please Go Online to see your Bookings',
              style: const TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        : provider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.red,
              ))
            : bookings.isEmpty
                ? Center(
                    child: Text(
                      'No requests found for $status bookings',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<AmbulanceBookingProvider>(context,
                          listen: false)
                          .fetchBookings();
                    },
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return BookingCard(

                          booking: booking,
                          onCancel: () async {
                            // Handle cancel
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Cancel Booking',
                                  style: CustomTextStyles.titleMedium,
                                ),
                                content: Text(
                                  'Are you sure you want to cancel this booking?',
                                  style: CustomTextStyles.titleMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'No',
                                      style: CustomTextStyles.titleSmall,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: CustomTextStyles.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              provider
                                  .deleteBooking(booking.bookingId);
                            }
                          },
                          onAccept: () async {
                            if (driverName!.isEmpty) {

                              flushBarErrorMsg(context, 'Profile Pending!', 'Complete your Profile to accept Booking.');
                            }else{
                               showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Accept Booking',
                                    style: CustomTextStyles.titleMedium,
                                  ),
                                  content: Text(
                                    'Are you sure you want to accept this booking?',
                                    style: CustomTextStyles.titleMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text(
                                        'No',
                                        style: CustomTextStyles.titleSmall,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop(false);
                                        await provider
                                            .acceptBooking(
                                            booking.bookingId,
                                            driverId!,
                                            context);
                                      },
                                      child: Text(
                                        'Yes',
                                        style: CustomTextStyles.titleSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          onCompleted: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Complete Booking?',
                                  style: CustomTextStyles.titleMedium,
                                ),
                                content: Text(
                                  'Have you Completed this Booking?',
                                  style: CustomTextStyles.titleMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      'No',
                                      style: CustomTextStyles.titleSmall,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                      await provider
                                          .completeBooking(
                                          booking.bookingId,
                                          driverId!,
                                          context);
                                      booking.confirmStatus = 'Completed';
                                    },
                                    child: Text(
                                      'Yes',
                                      style: CustomTextStyles.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // ambulanceProvider.acceptBooking(booking.bookingId);
                            }
                          },
                        );
                      },
                    ),
                  );
  }
}

class BookingCard extends StatelessWidget {
  final dynamic booking;

  final VoidCallback onCancel;
  final VoidCallback onAccept;
  final VoidCallback onCompleted;

   BookingCard({
    Key? key,

    required this.booking,
    required this.onCancel,
    required this.onAccept,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 6,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    booking.name,
                    style: CustomTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'Time: ${booking.bookingTime}',
                    style: CustomTextStyles.titleSmall
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    'assets/images/tracking.png',
                    width: 50,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PickUp: ${booking.pickupLocation}",
                          style: CustomTextStyles.titleSmall,
                        ),
                        Text(
                          "Destination: ${booking.destination}",
                          style: CustomTextStyles.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (booking.confirmStatus == 'pending' ||
                      booking.confirmStatus == 'Accepted')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                  // Accept Button
                  if (booking.confirmStatus == 'pending') ...[
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                  // Complete Button
                  if (booking.confirmStatus == 'Accepted') ...[
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: ()async{
                          // Request permission to make a phone call
                         bool permissionGranted = await Permission.phone.request().isGranted;
                          if (!permissionGranted) {
                            return flushBarErrorMsg(context, "Missing Call Permission", 'Please Allow Call Permission');
                          }else{
                            makePhoneCall('${booking.contactNumber}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Call Now'),
                      ),
                    ),
                  ],
                  // Complete Button
                  if (booking.confirmStatus == 'Accepted') ...[
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCompleted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                  ],

                  // Cancelled (Non-clickable) Button
                  if (booking.confirmStatus == 'Canceled') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {}, // Non-clickable
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red),
                        child: const Text('Cancelled'),
                      ),
                    ),
                  ],
                  // Completed (Non-clickable) Button
                  if (booking.confirmStatus == 'Completed') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {}, // Non-clickable
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green),
                        child: const Text('Completed'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {

    try {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: '+91$phoneNumber', // Concatenate country code with the number
      );

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      debugPrint('Eeeeeeeeeeeeeeeeeeeeeeeeeee: $e');
    }
  }

}
