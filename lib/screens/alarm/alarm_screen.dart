import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/model/alarm_description_model.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final alarms = AlarmDescriptionModel.instance.alarmDescription;
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Stelling')),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: alarms.length,
        separatorBuilder: (_, index) =>
            const Divider(height: 1, indent: 72, color: Color(0xFFE7E8EA)),
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return Material(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/icon/alarm.png',
                  excludeFromSemantics: true,
                ),
              ),
              title: Text(
                alarm['title'].toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  alarm['sub_title'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF73777D),
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF73777D),
              ),
              onTap: () => Navigator.of(context).pushNamed(
                '/alarm_board',
                arguments: jsonEncode({...alarm, 'code': index}),
              ),
            ),
          );
        },
      ),
    );
  }
}
