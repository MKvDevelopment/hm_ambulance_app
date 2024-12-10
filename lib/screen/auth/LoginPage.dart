import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_code/custom_elevated_button.dart';
import '../../constants.dart';
import '../../provider/AuthProvider.dart';
import '../../route_constants.dart';
import 'login_form.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscureTextNotifier = ValueNotifier<bool>(true);  // For password visibility toggle



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Consumer<AuthProviderr>(
      builder: (context, provider, child) {

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  children: [
                    Image.asset(
                      loginPageImg,
                      fit: BoxFit.cover,
                      height: height*2/8,
                    ),
                    Padding(

                      padding: kIsWeb? EdgeInsets.symmetric(horizontal:width>600?width*0.2:defaultPadding):const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(loginPageTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          Text(loginPageDesc,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: defaultPadding),
                          LogInForm(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscureTextNotifier: _obscureTextNotifier),
                          SizedBox(
                            height: size.width > 600
                                ? size.height * 0.1
                                : defaultPadding,
                          ),

                          provider.isLoading ? CircularProgressIndicator(color: Theme.of(context).appBarTheme.backgroundColor,) :
                          CustomElevatedButton(
                            onPressed: () {

                              if (_formKey.currentState!.validate()) {
                                provider.isLoadingValue = true;
                                FocusScope.of(context).unfocus();
                                provider.signInWithEmailAndPassword(
                                    context,
                                    _emailController.text,
                                    _passwordController.text
                                );
                              }
                            },
                            labelText: provider.isLoading ?  const CircularProgressIndicator(color: Colors.white,) : Text('Login'),
                          ),
                          SizedBox(
                            height: size.height * 0.20
                          ),
                          RichText(text: TextSpan(
                              text: 'Don\'t have an account? ',
                              style: Theme.of(context).textTheme.titleSmall,
                              children: [
                                TextSpan(
                                    text: 'Sign up',
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      Navigator.pushNamedAndRemoveUntil(context, signUpScreenRoute, (route) => false);
                                    },
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                    ))
                              ]
                          ))
                        ],
                      ),
                    )
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
