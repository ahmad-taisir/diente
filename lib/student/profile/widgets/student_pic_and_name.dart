import 'package:diente/student/data/models/student.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StudentPicAndName extends StatefulWidget {
  StudentModel student;
  StudentPicAndName({super.key, required this.student});

  @override
  State<StudentPicAndName> createState() => _StudentPicAndNameState();
}

class _StudentPicAndNameState extends State<StudentPicAndName> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: widget.student.profilePic.isNotEmpty
              ? NetworkImage(widget.student.profilePic)
              : null,
          child: widget.student.profilePic.isEmpty
              ? Text(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  '${widget.student.name[0].toUpperCase()}${widget.student.name[1].toUpperCase()}')
              : null,
        ),
        Gap(20.h),
        Center(
          child: Text(
            widget.student.name,
            style: TextStyle(
              color: const Color(0xFF1B2A57),
              fontSize: 20.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 0.h,
            ),
          ),
        ),
        Gap(20.h),
        Text(
          'Reports',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1B2A57),
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 0.h,
          ),
        ),
        Gap(28.h),
      ],
    );
  }
}
