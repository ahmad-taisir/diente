import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diente/auth/data/models/user.dart';
import 'package:diente/auth/data/source/auth_firebase_service.dart';
import 'package:diente/auth/presentation/email_verification_screen.dart';
import 'package:diente/auth/presentation/home_screen.dart';
import 'package:diente/auth/presentation/login_screen.dart';
import 'package:diente/auth/presentation/create_new_password_screen.dart';
import 'package:diente/auth/presentation/fill_information_screen.dart';
import 'package:diente/auth/presentation/medical_history_screen.dart';
import 'package:diente/auth/presentation/signup_screen.dart';
import 'package:diente/firebase_options.dart';
import 'package:diente/patient/home/patient_home_screen.dart';
import 'package:diente/patient/Review%20case%20information/case_info_screen.dart';
import 'package:diente/patient/Review%20case%20information/no_cases_screen.dart';
import 'package:diente/patient/appointment%20booking/disease_selection_screen.dart';
import 'package:diente/patient/appointment%20booking/teeth_selection_%20screen.dart';
import 'package:diente/patient/edit%20profile%20info/edit_patient_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/lightmode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() async {
    super.initState();
  }

  Widget initialScreen() {
    return FutureBuilder(
      future: AuthFirebaseService().fetchUser(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading user data"));
        }

        // Check if data has been fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          // No user is signed in, show login screen
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          // Email is not verified, show email verification screen
          return const EmailVerificationScreen();
        }

        final UserModel? userData = snapshot.data;

        if (userData == null ||
            userData.firstName.isEmpty ||
            userData.secondName.isEmpty ||
            userData.age.isEmpty ||
            userData.phoneNum.isEmpty) {
          // If user data is incomplete, navigate to fill profile screen
          return const FillProfileScreen();
        }

        // If everything is okay, go to HomeScreen
        return const HomeScreen();
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //log(user!.emailVerified.toString());
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp(
          home: initialScreen(),
          routes: {
            //home screen
            "/home_screen": (context) => const HomeScreen(),
            //login screen
            "/login_screen": (context) => const LoginScreen(),
            //signup screen
            "/signup_screen": (context) => const SignupScreen(),
            //fill profile info screen
            "/fill_profile_screen": (context) => const FillProfileScreen(),
            //fill medical history screen
            // "/fill_medical_history_screen": (context) =>
            //     const MedicalHistoryScreen(),
            //fill medical history screen
            "/create_new_password_screen": (context) =>
                const CreateNewPasswordScreen(),
            //email verification screen
            "/email_verification_screen": (context) =>
                const EmailVerificationScreen(),

            //Patient UI

            //patient home screen
            // "patient_home_screen": (context) => PatientHomeScreen(
            //       patientName: "Patient name",
            //       patientImage: const AssetImage("assets/images/patient.png"),
            //     ),
            //case information screen
            // "case_info_screen": (context) => CaseInformationScreen(
            //     patientName: "Patient name",
            //     patientImage: const AssetImage("assets/images/patient.png"),
            //     caseStatus: "Waiting"),
            //no cases screen
            // "no_cases_screen": (context) => NoCasesScreen(
            //     patientName: "Patient name",
            //     patientImage: const AssetImage("assets/images/patient.png")),
            // //disease selection screen
            // "disease_selection_screen": (context) => DiseaseSelectionScreen(
            //     patientName: "Patient name",
            //     patientImage: const AssetImage("assets/images/patient.png")),
            // //teeth selection screen
            // "teeth_selection_screen": (context) => TeethSelectionScreen(
            //     patientName: "Patient name",
            //     patientImage: const AssetImage("assets/images/patient.png")),
            //edit patient profile screen
            "edit_profile_screen": (context) => EditPatientProfileScreen(
                patientName: "Patient name",
                patientImage: const AssetImage("assets/images/patient.png")),
          },
          theme: lightMode,
        ));
  }
}
