import 'dart:developer';
import 'package:diente/core/widgets/buttons.dart';
import 'package:diente/core/widgets/google.dart';
import 'package:diente/core/widgets/text.dart';
import 'package:diente/core/widgets/text_fields.dart';
import 'package:diente/student/login/login_bloc/bloc/login_bloc.dart';
import 'package:diente/student/login/login_bloc/bloc/login_event.dart';
import 'package:diente/student/login/login_bloc/bloc/login_state.dart';
import 'package:diente/student/profile/screens/control_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      log("Email: ${FirebaseAuth.instance.currentUser!.email}");
    } else {
      log('No student logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home_screen');
          },
        ),
      ),
      body: BlocProvider(
        create: (context) => StudentLoginBloc(),
        child: BlocConsumer<StudentLoginBloc, StudentLoginState>(
          listener: (context, state) {
            log('state$state');
            if (state is StudentLoginSuccess) {
              if (FirebaseAuth.instance.currentUser!.emailVerified) {
                log('Login successful, navigating to the next screen');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return const ControlScreen();
                  }),
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.popAndPushNamed(
                    context, '/email_verification_screen');
              }
            } else if (state is StudentLoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (context, state) {
            if (state is StudentLoginLoading && state.isLoading) {
              return Center(child: Image.asset('assets/images/loading.gif'));
            }
            return StudentLoginBodyWidget(
              emailController: emailController,
              passwordController: passwordController,
            );
          },
        ),
      ),
    );
  }
}

class StudentLoginBodyWidget extends StatefulWidget {
  const StudentLoginBodyWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<StudentLoginBodyWidget> createState() => _StudentLoginBodyWidgetState();
}

class _StudentLoginBodyWidgetState extends State<StudentLoginBodyWidget> {
  bool passwordVisible = true;
  final GlobalKey<FormState> formKey = GlobalKey();

  String? validateField(String? value) {
    return (value == null || value.isEmpty)
        ? 'This field cannot be empty'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            customText(
              context,
              'Sign in to your \nAccount',
              Theme.of(context).colorScheme.primary,
              32.sp,
              FontWeight.bold,
            ),
            Gap(50.h),
            CustomTextField(
              width: 343.w,
              height: 56.h,
              controller: widget.emailController,
              text: 'Enter your email',
              validator: validateField,
              onSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  BlocProvider.of<StudentLoginBloc>(context).add(
                    StudentSubmitLogin(
                      email: widget.emailController.text,
                      password: widget.passwordController.text,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              validator: validateField,
              width: 343.w,
              height: 56.h,
              controller: widget.passwordController,
              text: 'Enter your password',
              icon: passwordVisible ? Icons.visibility : Icons.visibility_off,
              hide: passwordVisible,
              iconPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            ),
            SizedBox(height: 16.h),
            Gap(70.h),
            customButton(
              context,
              Theme.of(context).colorScheme.secondary,
              () {
                if (formKey.currentState!.validate()) {
                  BlocProvider.of<StudentLoginBloc>(context).add(
                    StudentSubmitLogin(
                      email: widget.emailController.text,
                      password: widget.passwordController.text,
                    ),
                  );
                }
              },
              'Login',
              16.sp,
            ),
            Gap(36.h),
            GestureDetector(
              onTap: () => Navigator.popAndPushNamed(
                  context, '/create_new_password_screen'),
              child: Center(
                child: customText(
                  context,
                  'Forgot Password?',
                  Theme.of(context).colorScheme.secondary,
                  14.sp,
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
