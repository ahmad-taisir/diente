import 'dart:developer';

import 'package:diente/auth/data/source/auth_firebase_service.dart';
import 'package:diente/auth/presentation/bloc/login_bloc/bloc/login_bloc.dart';
import 'package:diente/auth/presentation/bloc/login_bloc/bloc/login_event.dart';
import 'package:diente/auth/presentation/bloc/login_bloc/bloc/login_state.dart';
import 'package:diente/core/widgets/buttons.dart';
import 'package:diente/core/widgets/google.dart';
import 'package:diente/core/widgets/text.dart';
import 'package:diente/core/widgets/text_fields.dart';
import 'package:diente/patient/data/database%20services/case_status.dart';
import 'package:diente/patient/data/database%20services/requests_database_services.dart';
import 'package:diente/patient/presentation/Review%20case%20information/case_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../patient/presentation/Home/patient_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email, password;

  bool isLoading = false;

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      log("Email: ${FirebaseAuth.instance.currentUser!.email}");
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => PatientHomeScreen()),
      //   (route) => false,
      // );
    } else {
      log('No user logged in');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/home_screen');
            },
          ),
          actions: const []),
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state is LoginSuccess) {
              if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
                try {
                  log('Login successful, navigating to the next screen');

                  if (await RequestDatabaseServices().checkCaseExistence(
                      FirebaseAuth.instance.currentUser!.uid)) {
                    log('check case status');
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return CaseInformationScreen(
                        user: state.user,
                      );
                    }), (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return PatientHomeScreen(
                        userModel: state.user,
                      );
                    }), (Route<dynamic> route) => false);
                  }
                } catch (e, stackTrace) {
                  log('Navigation error: $e', error: e, stackTrace: stackTrace);
                }
              } else if (FirebaseAuth.instance.currentUser!.emailVerified ==
                  false) {
                Navigator.popAndPushNamed(
                    context, '/email_verification_screen');
              }
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (context, state) {
            if (state is LoginLoading) {
              if (state.isLoading == true) {
                return Center(child: Image.asset('assets/images/loading.gif'));
              } else {
                return bodyWidget(
                    emailController: emailController,
                    passwordController: passwordController);
              }
            }
            return bodyWidget(
                emailController: emailController,
                passwordController: passwordController);
          },
        ),
      ),
    );
  }
}

/// ***************** body widget *******************
class bodyWidget extends StatefulWidget {
  const bodyWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<bodyWidget> createState() => _bodyWidgetState();
}

class _bodyWidgetState extends State<bodyWidget> {
  bool passwordVisible = true; // to show or hide password
  GlobalKey<FormState> formKey = GlobalKey(); //to validate form

  String validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل لا يمكن أن يكون فارغًا';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: customText(
                context,
                'تسجيل الدخول',
                Theme.of(context).colorScheme.primary,
                30.sp,
                FontWeight.bold,
              ),
            ),
            Gap(77.h),
            CustomTextField(
              width: 343.w,
              height: 56.h,
              controller: widget.emailController,
              text: 'أدخل بريدك الإلكتروني',
              validator: validateField,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              validator: validateField,
              width: 343.w,
              height: 56.h,
              controller: widget.passwordController,
              text: 'أدخل كلمة المرور',
              icon: passwordVisible ? Icons.visibility : Icons.visibility_off,
              hide: passwordVisible,
              iconPressed: () {
                log(passwordVisible.toString());
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
              onSubmitted: (value) {
                BlocProvider.of<LoginBloc>(context).add(
                  SubmitLogin(
                    email: widget.emailController.text,
                    password: widget.passwordController.text,
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            Gap(70.h),
            customButton(
              context,
              Theme.of(context).colorScheme.secondary,
              () {
                BlocProvider.of<LoginBloc>(context).add(
                  SubmitLogin(
                    email: widget.emailController.text,
                    password: widget.passwordController.text,
                  ),
                );
              },
              'تسجيل الدخول',
              16.sp,
            ),
            Gap(36.h),
            GestureDetector(
              onTap: () => Navigator.popAndPushNamed(
                  context, '/create_new_password_screen'),
              child: Center(
                child: customText(
                  context,
                  ' نسيت كلمة السر؟ ',
                  Theme.of(context).colorScheme.secondary,
                  14.sp,
                  FontWeight.w500,
                ),
              ),
            ),
            Gap(24.h),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.popAndPushNamed(context, '/signup_screen');
                      },
                      child: customText(
                          context,
                          'إنشاء حساب',
                          Theme.of(context).colorScheme.secondary,
                          14.sp,
                          FontWeight.normal),
                    ),
                    customText(
                      context,
                      ' ليس لديك حساب؟ ',
                      Theme.of(context).colorScheme.primary,
                      14.sp,
                      FontWeight.normal,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
