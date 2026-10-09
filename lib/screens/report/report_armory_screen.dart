import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportArmoryScreen extends StatefulWidget {
  const ReportArmoryScreen({Key? key}) : super(key: key);

  @override
  State<ReportArmoryScreen> createState() => _ReportArmoryScreenState();
}

class _ReportArmoryScreenState extends State<ReportArmoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Rekap Data Gudang Senjata"),
      ),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportGudangSenjata,
      itemBuilder: (context, value) => ReportEntry(data: value, armory: true),
    );
  }
}
