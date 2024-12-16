import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:IM_Ambulance/common_code/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();



  // Method to pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Method to upload image to Firebase Storage
  Future<void> _uploadImage() async {

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected!")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('driverImage/${DateTime.now().toIso8601String()}.jpg');

      // Upload the file to Firebase Storage
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the driver's profile image in Firestore
      await firebaseFirestore
          .collection('driverList')
          .doc(await getDriverId())
          .update({'profileImage': downloadUrl});

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebse Error uploading image!")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Image"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: height/1.5,
                      width: width,
                      fit: BoxFit.fill,
                    )
                  : Container(
                      height: 400,
                      width: width,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image, size: 100, color: Colors.grey[700]),
                    ),
              SizedBox(height: 16),
              Spacer(),
              Expanded(child:   _isUploading
                  ? Center(child: CircularProgressIndicator(color: Colors.red,))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: CustomElevatedButton(
                          labelText: const Text('Select Image'),
                          onPressed: _pickImage)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: CustomElevatedButton(
                          labelText: const Text('Upload Image'),
                          onPressed: _uploadImage)),
                ],
              ),),

            ],
          ),
        ),
      ),
    );
  }

  Future<String> getDriverId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('driverId') ?? '';
  }
}
