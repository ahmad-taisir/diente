import 'dart:developer';
import 'dart:io';

import 'package:diente/core/widgets/buttons.dart';
import 'package:diente/core/widgets/text.dart';
import 'package:diente/patient/presentation/widgets/custom_text_field.dart';
import 'package:diente/student/data/models/report_model.dart';
import 'package:diente/student/data/models/student.dart';
import 'package:diente/student/data/services/choose_case.dart';
import 'package:diente/student/profile/widgets/student_pic_and_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants.dart';
import '../../data/services/reports_services.dart';
import '../widgets/list_reports.dart';

// ignore: camel_case_types
class MainStudentProfile extends StatefulWidget {
  const MainStudentProfile({super.key, required this.stdModel});
  final StudentModel stdModel;

  @override
  State<MainStudentProfile> createState() => _mainProfileState();
}

class _mainProfileState extends State<MainStudentProfile> {
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Pick from gallery
      );

      // If a file is picked, update the state to display it
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          log('sss');
        });
      }
    } catch (e) {
      log("Image selection error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: FutureBuilder(
            future: fetchAllReports(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              Widget customDailog(BuildContext context, ReportModel report) {
                return Center(
                  child: Container(
                    width: 332.w,
                    height: 453.h,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: report.reportPic.isNotEmpty
                        ? Image.network(
                            report.reportPic,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              List<ReportModel> reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return const Center(child: Text('No reports available'));
              }
              return CustomScrollView(slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate([
                  Center(
                    child: StudentPicAndName(
                      student: widget.stdModel,
                    ),
                  ),
                  Gap(28.h),
                ])),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return customDailog(context, reports[index]);
                              });
                        },
                        child: Card(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            child: Center(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  "${aToE[reports[index].caseName]}"),
                            )),
                      );
                    },
                    childCount: reports.length,
                  ),
                ),
              ]);
            }));
  }
}
