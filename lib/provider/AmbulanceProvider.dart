import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../route_constants.dart';
import '../screen/ambulance/AmbulanceBookingModel.dart';

class AmbulanceBookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 //  List<AmbulanceModel> bookings=[];
  final List<AmbulanceModel> _pendingBooking = [];
  final List<AmbulanceModel> _acceptedBooking = [];
  final List<AmbulanceModel> _completedBooking = [];
  List<AmbulanceModel> get pendingBooking => _pendingBooking;
  List<AmbulanceModel> get acceptedBooking => _acceptedBooking;
  List<AmbulanceModel> get completedBooking => _completedBooking;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Method to delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('ambulanceBookings')
          .doc(bookingId)
          .update({
            'confirmStatus': 'Canceled',
            'driverId': null,
          });
      // Remove the item locally as well
    //  bookings.removeWhere((booking) => booking.bookingId == bookingId);
      notifyListeners();
    } catch (error) {
      print("Failed to delete booking: $error");
    }
  }

  Future<void> fetchBookings() async {
    isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ambulanceBookings')
          .get();
      _pendingBooking.clear();
      _acceptedBooking.clear();
      _completedBooking.clear();

      for(var doc in snapshot.docs){
        AmbulanceModel booking = AmbulanceModel.fromMap(doc.data() as Map<String, dynamic>);
        if(booking.confirmStatus=='pending'){
          _pendingBooking.add(booking);
        }else if(booking.confirmStatus=='Accepted'){
          _acceptedBooking.add(booking);
        }else if(booking.confirmStatus=='Completed'){
          _completedBooking.add(booking);
        }
      }

      // bookings = snapshot.docs.map((doc) {
      //   return AmbulanceModel.fromMap(doc.data() as Map<String, dynamic>);
      // }).toList();

    } catch (e) {
      print("Error fetching bookings: $e");
    }finally{

      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> acceptBooking(String bookingId, String driverId,BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try{
      await FirebaseFirestore.instance.
      collection('ambulanceBookings')
          .doc(bookingId)
          .update({
        'confirmStatus': 'Accepted',
        'driverId': driverId,
      });

      int index=_pendingBooking.indexWhere((element) => element.bookingId==bookingId);
      if(index==-1){
        AmbulanceModel booking=_pendingBooking.removeAt(index);

        booking.confirmStatus='Accepted';
        _acceptedBooking.add(booking);

        return;
      }
      isLoading = false;
      // Display success message
      fetchBookings();
      flushBarSuccessMsg(context, "Success!", "Appointment Accepted Successfully.");
      notifyListeners();
    }catch(error){
      notifyListeners();
      flushBarSuccessMsg(context, "Error!", "Error: $error");
    }finally{
      // Reset loading state
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> completeBooking(String bookingId, String driverId,BuildContext context) async {
    try{
      await FirebaseFirestore.instance.
      collection('ambulanceBookings')
          .doc(bookingId)
          .update({
        'confirmStatus': 'Completed',
        'driverId': driverId,
      });

      int index=_acceptedBooking.indexWhere((element) => element.bookingId==bookingId);
      if(index==-1){
        AmbulanceModel booking=_acceptedBooking.removeAt(index);

        booking.confirmStatus='Completed';
        _completedBooking.add(booking);

        return;
      }
      isLoading = false;
      // Display success message
      fetchBookings();
      flushBarSuccessMsg(context, "Success!", "Appointment Completed Successfully.");
      notifyListeners();
    }catch(error){
      notifyListeners();
    }
  }
}
