// ignore_for_file: must_be_immutable
import 'package:diente/patient/presentation/Review%20case%20information/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../edit profile info/edit_patient_profile_screen.dart';

class CustomHeader extends StatelessWidget {
  final String? patientName;
  final ImageProvider? patientImage;

  const CustomHeader(
      {super.key, required this.patientName, required this.patientImage});

  @override
  Widget build(BuildContext context) {
    //patient image, name and notifications icon
    return SizedBox(
      height: 80.h,
      width: 375.w,
      child: Stack(
        children: [
          //image & name
          Positioned(
            left: 16.w,
            top: 20.h,
            child: InkWell(
                child: Row(
                  children: [
                    //patient image
                    Center(
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          patientName != null && patientName!.isNotEmpty
                              ? patientName!
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join()
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    //patient name
                    Text(
                      patientName!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  //TODO: navigate to edit profile screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EditPatientProfileScreen(
                      patientName: patientName!,
                      patientImage: patientImage ??
                          const AssetImage('assets/images/patient.png'),
                    );
                  }));
                }),
          ),
          //notifications icon
          // Positioned(
          //   right: 16.w,
          //   top: 20.h,
          //   child: IconButton(
          //     iconSize: 26.h,
          //     icon: const Icon(
          //       Icons.notifications,
          //       color: Color(0xFF7CA0CA),
          //     ),
          //     onPressed: () {
          //       //TODO: navigate to notifications screen
          //       Navigator.push(context, MaterialPageRoute(builder: (context) {
          //         return  NotificationsScreen();
          //       }));
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
