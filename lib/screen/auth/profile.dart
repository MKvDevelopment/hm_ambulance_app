import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hm_ambulance_app/common_code/custom_text_style.dart';
import 'package:hm_ambulance_app/route_constants.dart';
import 'package:hm_ambulance_app/screen/auth/StudentModel.dart';
import 'package:provider/provider.dart';

import '../../provider/AuthProvider.dart';
import '../UploadImageScreen.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController vehicleController;
  late TextEditingController experienceController;
  late TextEditingController addressController;
  bool isDataFetched = false;
  String imgUrl = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    vehicleController = TextEditingController();
    experienceController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isDataFetched) {
      final profileProvider = Provider.of<AuthProviderr>(context, listen: false);
      profileProvider.fetchAuth(context).then((_) {
        // Populate controllers with fetched data
        final driver = profileProvider.driverModel;
        nameController.text = driver?.name ?? '';
        phoneController.text = driver?.mobileNo ?? '';
        emailController.text = driver?.email ?? '';
        vehicleController.text = driver?.vehicleNo ?? '';
        experienceController.text = driver?.experience ?? '';
        addressController.text = driver?.address ?? '';
        imgUrl = driver?.profileImage ?? '';
        setState(() {
          isDataFetched = true;
        });
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    vehicleController.dispose();
    experienceController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderr>(
      builder: (context, profileProvider, child) {

        return Scaffold(
          appBar: AppBar(
            title:  const Text('My Profile'),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            // Add logic for updating profile picture
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: imgUrl.isNotEmpty ? NetworkImage(imgUrl) : const AssetImage('assets/images/driver_image.jpg'),
                          ),
                        ),
                        // Positioned Edit Icon
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              // Logic to edit the image
                              Navigator.pushNamed(context, changePasswordScreenRoute);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 10),
                     Text(
                      'Update Your Details',
                      style: CustomTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    ProfileDetailTextField(
                      label: 'Name',
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },   ),
                    ProfileDetailTextField(
                      label: 'Phone Number',
                      controller: phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number cannot be empty';
                        }
                        if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },    keyboardType: TextInputType.phone,
                    ),
                    ProfileDetailTextField(
                      label: 'Email',
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      }, keyboardType: TextInputType.emailAddress,
                    ),
                    ProfileDetailTextField(
                      label: 'Vehicle Number',
                      controller: vehicleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle number cannot be empty';
                        }
                        return null;
                      }, ),
                    ProfileDetailTextField(
                      label: 'Total Year Experience',
                      controller: experienceController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Experience cannot be empty';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Experience must be a number';
                        }
                        return null;
                      }, ),
                    ProfileDetailTextField(
                      label: 'Address',
                      controller: addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Address cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Update Profile Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() == true) {
                         // Validation successful, proceed to update profile
                          String uid=FirebaseAuth.instance.currentUser!.uid;
                          DriverModel driver=new DriverModel(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              experience: experienceController.text.trim(),
                              mobileNo: phoneController.text.trim(),
                              status:'Offline',
                              profileImage:imgUrl,
                              vehicleNo: vehicleController.text.trim(),
                              address: addressController.text.trim(),
                              driverId: uid);
                          await profileProvider.updateProfile(driver,context);

                        } else {
                          // Validation failed
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fix the errors')),
                          );
                        }

                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class ProfileDetailTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Add validator


  const ProfileDetailTextField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
          style: CustomTextStyles.titleMedium,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 1.0,horizontal: 10.0)
        ),
        validator: validator,
      ),
    );
  }
}
