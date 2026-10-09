import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportVehicleVanPermissionScreen extends StatefulWidget {
  const ReportVehicleVanPermissionScreen({Key? key}) : super(key: key);

  @override
  State<ReportVehicleVanPermissionScreen> createState() =>
      _ReportVehicleVanPermissionScreenState();
}

class _ReportVehicleVanPermissionScreenState
    extends State<ReportVehicleVanPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Rekap Data Perizinan Ranpur"),
      ),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportPerizinanRanpur,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
