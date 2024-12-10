import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

const String loginPageImg="assets/images/login.png";
const String loginPageTitle="Welcome back!";
const String loginPageDesc="Log in with your data that you Entered during your registration.";

const String registerPageImg="assets/images/signup.png";
const String registerPageTitle="Create Your Account!";
const String registerPageDesc="Enter your details below to create a new account.";


const Color cardBackgroundColor = Color(0xFFF4F3F6);
const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);
const Color whiteColor = Colors.white;

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

var doctorList=["Dr.Manish","Dr.Vikash","Dr.Vinit","Dr.Nidhi","Dr.Tanya"];
var doctorCategory=["General Physican","Dentist","Ent Specialist (Otolaryngologist)","Ophthalmologis","Neurologist"];


final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(6, errorText: 'password must be at least 6 digits long'),
  // PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";



void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: errorColor,
    ),
  );
}

void flushBarErrorMsg(BuildContext context, String title, String msg) {
  Flushbar(
    title: title,
    message: msg,
    flushbarPosition: FlushbarPosition.TOP,
    forwardAnimationCurve: Curves.decelerate,
    reverseAnimationCurve: Curves.decelerate,
    isDismissible: false,
    boxShadows: const [BoxShadow(color: Colors.red, offset: Offset(0.0, 2.0), blurRadius: 5.0)],
    duration:  const Duration(seconds: 3),
    margin:const  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    padding:const  EdgeInsets.all(10),
    backgroundGradient: LinearGradient(colors: [Colors.red.shade100, Colors.red]),
    icon:const  Icon(Icons.error_outline, color: whiteColor),
    backgroundColor: errorColor,
  ).show(context);
}

void flushBarSuccessMsg(BuildContext context, String title, String msg) {
  Flushbar(
    title: title,
    message: msg,
    flushbarPosition: FlushbarPosition.BOTTOM,
    forwardAnimationCurve: Curves.decelerate,
    reverseAnimationCurve: Curves.decelerate,
    isDismissible: false,
    boxShadows:const  [BoxShadow(color: Colors.green, offset: Offset(0.0, 2.0), blurRadius: 5.0)],
    duration: const  Duration(seconds: 3),
    margin:const  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    padding:const  EdgeInsets.all(10),
    icon:const  Icon(Icons.check, color: whiteColor),
    backgroundGradient:const  LinearGradient(colors: [Colors.lightGreen, Colors.green]),
  ).show(context);
}


