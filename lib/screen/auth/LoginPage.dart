import 'package:IM_Ambulance/common_code/custom_text_style.dart';
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
  final ValueNotifier<bool> _obscureTextNotifier =
      ValueNotifier<bool>(true); // For password visibility toggle

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Consumer<AuthProviderr>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  height: 400,
                  'assets/images/view_eve.jpg',
                  fit: BoxFit.fitHeight,
                ),
              ),
              // Bottom Sheet for Login Content
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height / 2, // Half of the screen height
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: kIsWeb
                        ? EdgeInsets.symmetric(
                            horizontal:
                                width > 600 ? width * 0.2 : defaultPadding)
                        : const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          loginPageTitle,
                          style: CustomTextStyles.titleLarge,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          loginPageDesc,
                          style: CustomTextStyles.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: defaultPadding),
                        LogInForm(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscureTextNotifier: _obscureTextNotifier,
                        ),
                        const SizedBox(height: defaultPadding),
                        provider.isLoading
                            ? CircularProgressIndicator(
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor,
                              )
                            : CustomElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    provider.isLoadingValue = true;
                                    FocusScope.of(context).unfocus();
                                    provider.signInWithEmailAndPassword(
                                      context,
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                  }
                                },
                                labelText: provider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Login'),
                              ),
                        Spacer(),
                        Divider(
                          color: Colors.red,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: CustomTextStyles.titleSmall,
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        signUpScreenRoute, (route) => false);
                                  },
                                style: CustomTextStyles.titleSmall.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
