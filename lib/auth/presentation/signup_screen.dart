import 'dart:developer';

import 'package:diente/auth/presentation/bloc/signup_bloc/signup_bloc.dart';
import 'package:diente/auth/presentation/bloc/signup_bloc/signup_event.dart';
import 'package:diente/auth/presentation/bloc/signup_bloc/signup_state.dart';

import 'package:diente/core/widgets/buttons.dart';
import 'package:diente/core/widgets/google.dart';
import 'package:diente/core/widgets/text.dart';
import 'package:diente/core/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool passwordVisible = true; // to show or hide password
  GlobalKey<FormState> formKey = GlobalKey(); //to validate form
  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  //validate function
  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل لا يمكن أن يكون فارغًا';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
          actions: const []),

      /********** body **********/

      body: BlocProvider<SignupBloc>(
        create: (context) => SignupBloc(), //bloc creation
        child:
            BlocConsumer<SignupBloc, SignupState>(listener: (context, state) {
          //if signup success => navigate to verify email screen
          if (state is SignupSuccess) {
            try {
              log('Signup successful, navigating to the next screen');
              Navigator.popAndPushNamed(context, '/email_verification_screen');
            } catch (e, stackTrace) {
              log('Navigation error: $e', error: e, stackTrace: stackTrace);
            }
            //if signup failure => show snackbar error
          } else if (state is SignupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ));
          }
        }, builder: (context, state) {
          //if signup loading => show loading image ? else show signup form
          if (state is SignupLoading) {
            return Center(
              child: Image.asset('assets/images/loading.gif'),
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: customText(
                        context,
                        'انشاء حساب',
                        Theme.of(context).colorScheme.primary,
                        32.sp,
                        FontWeight.bold,
                      ),
                    ),
                    Gap(77.h),
                    CustomTextField(
                      width: 343.w,
                      height: 56.h,
                      controller: emailController,
                      text: 'ادخل البريد الالكتروني',
                      validator: validateField,
                    ),
                    Gap(16.h),
                    CustomTextField(
                      width: 343.w,
                      height: 56.h,
                      controller: passwordController,
                      text: 'ادخل كلمة المرور',
                      icon: passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      hide: passwordVisible,
                      iconPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      validator: validateField,
                    ),
                    Gap(16.h),
                    CustomTextField(
                      onSubmitted: (value) {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('الرجاء ملء جميع الحقول'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (passwordController.text ==
                            confirmPasswordController.text) {
                          if (formKey.currentState!.validate()) {
                            // Regular expression to check password strength
                            RegExp regex = RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@#$%^&+=]{8,}$');
                            if (regex.hasMatch(passwordController.text)) {
                              BlocProvider.of<SignupBloc>(context).add(
                                SubmitSignup(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، حرف واحد ورقم واحد على الأقل'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('كلمات المرور غير متطابقة'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      width: 343.w,
                      height: 56.h,
                      controller: confirmPasswordController,
                      text: 'تأكيد كلمة المرور',
                      icon: passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      hide: passwordVisible,
                      iconPressed: () {
                        //TODO:refactor
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      validator: validateField,
                    ),
                    Gap(90.h),
                    customButton(
                      context,
                      Theme.of(context).colorScheme.secondary,
                      () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('الرجاء ملء جميع الحقول'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (passwordController.text ==
                            confirmPasswordController.text) {
                          if (formKey.currentState!.validate()) {
                            // Regular expression to check password strength
                            RegExp regex = RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@#$%^&+=]{8,}$');
                            if (regex.hasMatch(passwordController.text)) {
                              BlocProvider.of<SignupBloc>(context).add(
                                SubmitSignup(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، حرف واحد ورقم واحد على الأقل'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('كلمات المرور غير متطابقة'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      'انشاء حساب',
                      16.sp,
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
                                Navigator.popAndPushNamed(
                                    context, '/login_screen');
                              },
                              child: customText(
                                  context,
                                  'تسجيل الدخول',
                                  Theme.of(context).colorScheme.secondary,
                                  14.sp,
                                  FontWeight.normal),
                            ),
                            customText(
                              context,
                              ' هل لديك حساب بالفعل؟ ',
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
        }),
      ),
    );
  }
}
