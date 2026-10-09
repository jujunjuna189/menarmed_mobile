import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportSuggestionScreen extends StatefulWidget {
  const ReportSuggestionScreen({Key? key}) : super(key: key);

  @override
  State<ReportSuggestionScreen> createState() => _ReportSuggestionScreenState();
}

class _ReportSuggestionScreenState extends State<ReportSuggestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Rekap Data Saran & Masukan"),
      ),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportSuggestion,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
