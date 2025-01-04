import 'dart:developer';
import 'dart:ffi';
import 'package:diente/auth/data/models/user.dart';
import 'package:diente/core/report_problem/data/model/report_problem_model.dart';
import 'package:diente/core/report_problem/data/source/report_problem.dart';
import 'package:diente/core/widgets/text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/database services/requests_database_services.dart';
import '../../data/models/case_details.dart';
import '../Review case information/case_info_screen.dart';
import '../Review case information/no_cases_screen.dart';
import '../appointment booking/disease_selection_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_header.dart';

// ignore: must_be_immutable

class PatientHomeScreen extends StatefulWidget {
  final UserModel? userModel;
  const PatientHomeScreen({super.key, required this.userModel});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  CaseDetails? caseDetails = CaseDetails();
  String? patientImage;
  final user = FirebaseAuth.instance.currentUser!.email!.split('@')[0];
  late final uid;
  late bool isExist;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    checkExistence();
  }

  Future<void> checkExistence() async {
    isExist = await RequestDatabaseServices().checkCaseExistence(uid);
  }

  @override
  Widget build(BuildContext context) {
    patientImage = widget.userModel!.profilePic.toString();
    // log('Patient Image: $patientImage');
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          //Header
          CustomHeader(
              patientName:
                  '${widget.userModel?.firstName} ${widget.userModel?.secondName}',
              patientImage: NetworkImage(patientImage!)),
          SizedBox(
            height: 101.h,
            width: 375.w,
          ),
          //Logo
          SizedBox(
              width: 214.28.w,
              height: 96.79.h,
              child: const Image(image: AssetImage("assets/images/logo2.png"))),
          SizedBox(
            height: 3.h,
          ),
          Center(
              child: Text(
            "best place for free dental treatment",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          )),
          SizedBox(
            height: 175.h,
            width: 375.w,
          ),

          //Appointment booking button
          CustomButton(
            width: 342.w,
            height: 55.h,
            borderRadius: 50.r,
            color: Theme.of(context).colorScheme.secondary,
            fontColor: Colors.white,
            borderColor: Theme.of(context).colorScheme.secondary,
            text: "حجز موعد جديد",
            onTap: () async {
              if (!isExist) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DiseaseSelectionScreen(
                          //edited
                          user: widget.userModel!,
                          caseDetails: caseDetails!)),
                );
              } else {
                log("already has a case");
                _dialogBuilder(context);
              }
            },
          ),

          //view case information button
          CustomButton(
            width: 342.w,
            height: 55.h,
            borderRadius: 50.r,
            color: Colors.white,
            fontColor: Theme.of(context).colorScheme.secondary,
            borderColor: Theme.of(context).colorScheme.secondary,
            text: "مراجعة معلومات الحالة",
            onTap: () async {
              if (isExist) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaseInformationScreen(
                            // caseDetails: caseDetails!,
                            user: widget.userModel!,
                            // caseStatus: "Active", //TODO: need to be edited
                          )),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NoCasesScreen(user: widget.userModel!)),
                );
              }
            },
          ),
          CustomButton(
            width: 342.w,
            height: 55.h,
            borderRadius: 50.r,
            color: Colors.red,
            fontColor: Colors.white,
            borderColor: Colors.red,
            text: "تسجيل الخروج",
            onTap: () async {
              log(FirebaseAuth.instance.currentUser!.email.toString());
              if (FirebaseAuth.instance.currentUser != null) {
                await FirebaseAuth.instance.signOut();
              }
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
          TextButton(
            onPressed: () {
              log('Report a problem button pressed');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController problemController =
                      TextEditingController();
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    title: customText(
                      context,
                      'الابلاغ عن مشكلة',
                      Theme.of(context).colorScheme.secondary,
                      16.sp,
                      FontWeight.w500,
                    ),
                    content: TextField(
                      controller: problemController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'صف مشكلتك هنا...',
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: customText(
                          context,
                          'الغاء',
                          Theme.of(context).colorScheme.secondary,
                          16.sp,
                          FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (problemController.text.isNotEmpty) {
                            ReportProblemModel report = ReportProblemModel(
                              description: problemController.text,
                              userId: uid,
                              timestamp: DateTime.now(),
                              userEmail:
                                  FirebaseAuth.instance.currentUser!.email!,
                            );
                            ReportProblemService().addReport(report);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: customText(
                                  context,
                                  'تم ارسال مشكلتك بنجاح',
                                  Colors.white,
                                  16.sp,
                                  FontWeight.w500,
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: customText(
                                  context,
                                  'الرجاء كتابة مشكلتك',
                                  Colors.white,
                                  16.sp,
                                  FontWeight.w500,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: customText(
                          context,
                          'تأكيد',
                          Theme.of(context).colorScheme.secondary,
                          16.sp,
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: customText(
              context,
              'الإبلاغ عن مشكلة',
              Theme.of(context).colorScheme.secondary,
              16.sp,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'تنبيه!',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              )),
          content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                "لقد قمت بحجز موعد مسبقاً,  لا يمكن حجز اكثر من موعد في آنٍ واحد",
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Theme.of(context).colorScheme.secondary),
              )),
          actions: const <Widget>[],
        );
      },
    );
  }
}
