import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportVehiclePermissionScreen extends StatefulWidget {
  const ReportVehiclePermissionScreen({Key? key}) : super(key: key);

  @override
  State<ReportVehiclePermissionScreen> createState() =>
      _ReportVehiclePermissionScreenState();
}

class _ReportVehiclePermissionScreenState
    extends State<ReportVehiclePermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text("Rekap Data Angkutan")),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportPerizinanKendaraan,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
