import 'package:diente/student/data/models/report_model.dart';
import 'package:diente/student/data/services/reports_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/constants.dart';
import '../widgets/student_pic_and_name.dart';

class ViewReports extends StatefulWidget {
  dynamic stdModel;

  ViewReports({super.key, required this.stdModel});

  @override
  State<ViewReports> createState() => _ViewReportsState();
}

class _ViewReportsState extends State<ViewReports> {
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
        ),
        body: FutureBuilder(
            future: fetchAllReports(widget.stdModel.id),
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
                reports.isNotEmpty
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return customDailog(
                                          context, reports[index]);
                                    });
                              },
                              child: Card(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  child: Center(
                                    child: Text(
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        "${aToE[reports[index].caseName]}"),
                                  )),
                            );
                          },
                          childCount: reports.length,
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No reports available',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )
              ]);
            }));
  }
}
