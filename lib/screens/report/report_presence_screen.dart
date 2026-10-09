import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/report_browser.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ReportPresenceScreen extends StatefulWidget {
  const ReportPresenceScreen({Key? key}) : super(key: key);

  @override
  State<ReportPresenceScreen> createState() => _ReportPresenceScreenState();
}

class _ReportPresenceScreenState extends State<ReportPresenceScreen> {
  String dateNowFormatter(String date, String format) {
    final DateTime dateNow = DateTime.parse(date);
    final DateFormat formatter = DateFormat(format);
    String formatDateNow = formatter.format(dateNow);
    return formatDateNow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text("Rekap Data Absensi")),
      body: buildReportList(),
    );
  }

  Widget buildReportList() {
    return ReportBrowser(
      url: Api.reportAbsensi,
      itemBuilder: (context, value) => ReportEntry(data: value),
    );
  }
}
