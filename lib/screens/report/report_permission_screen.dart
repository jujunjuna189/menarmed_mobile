import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportPermissionScreen extends StatefulWidget {
  const ReportPermissionScreen({Key? key}) : super(key: key);

  @override
  State<ReportPermissionScreen> createState() => _ReportPermissionScreenState();
}

class _ReportPermissionScreenState extends State<ReportPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text("Rekap Data Perizinan")),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportPerizinan,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
