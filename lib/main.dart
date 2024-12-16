import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:IM_Ambulance/provider/AmbulanceProvider.dart';
import 'package:IM_Ambulance/provider/AuthProvider.dart';
import 'package:IM_Ambulance/route_constants.dart';
import 'package:IM_Ambulance/screen/SplashScreen.dart';
import 'package:IM_Ambulance/screen/UploadImageScreen.dart';
import 'package:IM_Ambulance/screen/ambulance/AmbulanceBookingListPage.dart';
import 'package:IM_Ambulance/screen/auth/LoginPage.dart';
import 'package:IM_Ambulance/screen/auth/RegisterPage.dart';
import 'package:IM_Ambulance/screen/auth/profile.dart';
import 'package:provider/provider.dart';

import 'common_code/custom_text_style.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProviderr()),
    ChangeNotifierProvider(create: (_) => AmbulanceBookingProvider()),

  ],
    child: MyApp(),));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 24.0,),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          // Add more customization as needed
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding:  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme:  const TextTheme(

          bodyLarge: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Poppins'),
          bodyMedium: TextStyle(color: Colors.white,fontSize: 14),
          bodySmall: TextStyle(color: Colors.white,fontSize: 12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),

            ),
          ),
          elevation:5,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: CustomTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 10,

        ),
        listTileTheme: const ListTileThemeData(
            titleTextStyle: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),
            subtitleTextStyle: TextStyle(color: Colors.white,fontSize: 14),
            iconColor: Colors.white,
            visualDensity: VisualDensity(
                horizontal: 0,
                vertical: -4
            ),

            textColor: Colors.white
        ),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w500),
          contentTextStyle: TextStyle(color: Colors.white,fontSize: 16),
        ),
      ),
      themeMode: ThemeMode.light,
      initialRoute: splashScreenRoute,
      routes: {
        splashScreenRoute: (context) => const SplashScreen(),
        logInScreenRoute: (context) => const LoginScreen(),
        profileScreenRoute: (context) =>  const DriverProfilePage(),
        signUpScreenRoute: (context) => const RegisterPage(),
        ambulanceListScreenRoute: (context) => const AmbulanceBookingList(),

          changePasswordScreenRoute: (context) => const UploadImageScreen(),
      },
     );
  }
}
