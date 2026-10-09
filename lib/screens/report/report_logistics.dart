import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportLogisticsScreen extends StatefulWidget {
  const ReportLogisticsScreen({Key? key}) : super(key: key);

  @override
  State<ReportLogisticsScreen> createState() => _ReportLogisticsScreenState();
}

class _ReportLogisticsScreenState extends State<ReportLogisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text("Rekap Data Logistik")),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportLogistik,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
