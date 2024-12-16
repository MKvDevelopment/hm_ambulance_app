import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../route_constants.dart';
import '../screen/auth/StudentModel.dart';

class AuthProviderr with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  User? _user;
  bool isLoading = false;
  late DriverModel? driverModel;

  bool get isLoadingValue => isLoading;

  set isLoadingValue(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool get isAuthenticated => _user != null;

  User? get user => _user;

  AuthProviderr() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    // Close the keyboard
    FocusScope.of(context).unfocus();
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async => {
                if (value.user != null)
                  {
                    isLoadingValue = false,
                    flushBarSuccessMsg(context, "Success", "Login Successful"),
                    fetchStudent(context),
                  }
                else
                  {
                    flushBarErrorMsg(context, "Error", "Login Failed"),
                    isLoadingValue = false
                  }
              });
    } catch (e) {
      isLoadingValue = false;
      flushBarErrorMsg(context, "Error", "Login Failed");
      throw e.toString();
    }
  }

  // Method to fetch students from Firestore
  Future<void> fetchStudent(BuildContext context) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      DocumentSnapshot snapshot = await firebaseFirestore
          .collection('driverList')
          .doc(auth.currentUser?.uid)
          .get();
      if (snapshot.exists) {
        // Convert the document data to a StudentModel object
        driverModel =
            DriverModel.fromMap(snapshot.data() as Map<String, dynamic>);
        await saveUserDataToPreferences(driverModel!);

        // Navigate to home screen
        //Navigator.pushReplacementNamed(context, ambulanceListScreenRoute);
        Navigator.pushNamedAndRemoveUntil(
          context,
          ambulanceListScreenRoute,
          (route) => false, // Removes all routes in the stack
        );
        notifyListeners(); // Notify listeners so that the UI updates
      } else {
        // If the document does not exist
        flushBarErrorMsg(context, 'Error!', 'No Driver data found.');
        print("No Driver data found.");
      }
    } catch (error) {
      flushBarErrorMsg(context, 'Error!', 'Error fetching driver: $error');
      print("Error fetching driver: $error");
    }
  }

  Future<void> fetchAuth(BuildContext context) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      DocumentSnapshot snapshot = await firebaseFirestore
          .collection('driverList')
          .doc(auth.currentUser?.uid)
          .get();
      if (snapshot.exists) {
        // Convert the document data to a StudentModel object
        driverModel =
            DriverModel.fromMap(snapshot.data() as Map<String, dynamic>);
        await saveUserDataToPreferences(driverModel!);

        // Navigate to home screen
        //  Navigator.pushReplacementNamed(context, ambulanceListScreenRoute);
        notifyListeners(); // Notify listeners so that the UI updates
      } else {
        // If the document does not exist
        flushBarErrorMsg(context, 'Error!', 'No Driver data found.');
        print("No Driver data found.");
      }
    } catch (error) {
      flushBarErrorMsg(context, 'Error!', 'Error fetching driver: $error');
      print("Error fetching driver: $error");
    }
  }

  // Modify createUserWithEmailAndPassword method
  Future<void> createUserWithEmailAndPassword(BuildContext context, String email, String password) async {
    // Close the keyboard
    FocusScope.of(context).unfocus();
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (value.user != null) {
          isLoadingValue = false;

          // Create the student object
          DriverModel student = DriverModel(
            email: email,
            driverId: value.user!.uid,
            name: '',
            mobileNo: '',
            profileImage: '',
            vehicleNo: '',
            address: '',
            status: 'Offline',
            experience: '',
          );

          // Add student to Firestore
          await addDriver(student, context);

          // Show success message
          flushBarSuccessMsg(context, "Success", "Registration Successful");
          await saveUserDataToPreferences(student);
          // Navigate to home screen
          // Navigator.pushReplacementNamed(context, ambulanceListScreenRoute);
          Navigator.pushNamedAndRemoveUntil(
            context,
            ambulanceListScreenRoute,
            (route) => false, // Removes all routes in the stack
          );
        } else {
          flushBarErrorMsg(context, "Error", "Registration Failed");
          isLoadingValue = false;
        }
      });
    } catch (e) {
      isLoadingValue = false;
      flushBarErrorMsg(context, "Error", "Registration Failed");
      throw e.toString();
    }
  }

  Future<void> signOut(BuildContext context, String logInScreenRoute) async {
    await _auth.signOut();
    _user = null;
    notifyListeners();

    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    notifyListeners();
  }

  // Method to add a student to Firestore
  Future<void> addDriver(DriverModel driver, BuildContext context) async {
    try {
      isLoadingValue = true;

      // Add the student to the 'students' collection in Firestore
      await firebaseFirestore
          .collection('driverList')
          .doc(driver.driverId)
          .set(driver.toMap())
          .then((onValue) {
        // flushBarSuccessMsg(context, "Success", "Student added successfully");
      }).onError((error, stackTrace) {
        flushBarErrorMsg(context, "Error", "Failed to add Driver");
      });
    } catch (error) {
      print("Error adding student: $error");
      flushBarErrorMsg(context, "Error", "$error");
    } finally {
      isLoadingValue = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isLoadingValue = true;
    notifyListeners();

    final user = _auth.currentUser;

    if (user == null) {
      isLoadingValue = false;
      notifyListeners();
      throw FirebaseAuthException(
          code: 'no-user', message: 'No user is signed in.');
    }

    // Re-authenticate the user
    final email = user.email!;
    final credential =
        EmailAuthProvider.credential(email: email, password: oldPassword);

    try {
      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } finally {
      isLoadingValue = false;
      notifyListeners();
    }
  }

  // Update data on Firebase
  Future<void> updateProfile(DriverModel driverModel, BuildContext context) async {
    try {
      await firebaseFirestore
          .collection('driverList')
          .doc(driverModel.driverId)
          .update(driverModel.toMap())
          .then((v) async {
       await saveUserDataToPreferences(driverModel);
        flushBarSuccessMsg(context, "Success", "Profile updated successfully");
      }).onError((error, stakTrast) {
        flushBarErrorMsg(context, "Error", "$error");
      });
      notifyListeners();
    } catch (error) {
      print("Failed to update profile: $error");
    }
  }

  // Method to save data in SharedPreferences
  Future<void> saveUserDataToPreferences(DriverModel driverModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driverId', driverModel.driverId);
    await prefs.setString('email', driverModel.email!);
    await prefs.setString('name', driverModel.name!);
    await prefs.setString('mobileNo', driverModel.mobileNo);
    await prefs.setString('profileImage', driverModel.profileImage);
    await prefs.setString('experience', driverModel.experience);
    await prefs.setString('vehicleNo', driverModel.vehicleNo);
    await prefs.setString('status', driverModel.status);
    await prefs.setString('address', driverModel.address);
  }

  Future<DriverModel?> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve saved data
    String driverId = prefs.getString('driverId') ?? '';
    String? email = prefs.getString('email');
    String? name = prefs.getString('name');
    String? profileImage = prefs.getString('profileImage');
    String? mobileNo = prefs.getString('mobileNo');
    String? experience = prefs.getString('experience');
    String? vehicleNo = prefs.getString('vehicleNo');
    String? rating = prefs.getString('rating');
    String? status = prefs.getString('status');
    String? address = prefs.getString('address');

    // Check if the studentId exists (indicating that data is saved)
    if (driverId != null && email != null) {
      // Return a StudentModel object with the retrieved values
      return DriverModel(
        email: email,
        driverId: driverId,
        name: name ?? '',
        profileImage: profileImage ?? '',
        mobileNo: mobileNo ?? '',
        experience: experience ?? '',
        vehicleNo: vehicleNo ?? '',
        status: status ?? '',
        address: address ?? '',
      );
    } else {
      // If no data is found, return null
      return null;
    }
  }

  Future<void> updateDriverStatus(String driverId, String newStatus) async {
    // Update Firestore
    try {
      await firebaseFirestore
          .collection('driverList')
          .doc(driverId)
          .update({'status': newStatus});

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status', newStatus);

      notifyListeners(); // Notify listeners to rebuild UI if necessary
    } catch (error) {
      print("Error updating status: $error");
    }
  }
}
