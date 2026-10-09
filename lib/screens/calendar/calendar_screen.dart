import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menarmed_mobile/repository/calendar_repo.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List _events = [];
  final Map<String, List> _dayEvents = {};
  bool _expanded = false;
  bool _loading = false;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents(_selectedDay);
  }

  Future<void> _loadEvents(DateTime day) async {
    final request = ++_request;
    setState(() {
      _selectedDay = day;
      _loading = true;
      _failed = false;
      _events = [];
    });
    try {
      final result = await CalendarRepo.instance.show({
        'date_from': DateFormat('yyyy-MM-dd').format(
          DateTime(day.year, day.month, 1).subtract(const Duration(days: 7)),
        ),
        'date_to': DateFormat('yyyy-MM-dd').format(
          DateTime(day.year, day.month + 1, 0).add(const Duration(days: 7)),
        ),
      });
      if (!mounted || request != _request) return;
      setState(() {
        _dayEvents.clear();
        if (result is Iterable) {
          for (final event in result) {
            final date = DateTime.tryParse(event['tanggal']?.toString() ?? '');
            if (date != null) {
              final key = DateFormat('yyyy-MM-dd').format(date);
              (_dayEvents[key] ??= []).add(event);
            }
          }
        }
        _events = _dayEvents[DateFormat('yyyy-MM-dd').format(day)] ?? [];
        _failed = result is! Iterable;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Color _eventColor(String color) {
    return switch (color) {
      'success' => const Color(0xFF22724C),
      'primary' => const Color(0xFF3468AB),
      'warning' => const Color(0xFFAA740D),
      'dark' => const Color(0xFF555A60),
      _ => const Color(0xFF9E3434),
    };
  }

  String _monthLabel(DateTime day) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[day.month - 1]} ${day.year}';
  }

  String _dateLabel(DateTime day) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[day.weekday - 1]}, ${day.day} ${_monthLabel(day)}';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F5F6),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _monthLabel(_focusedDay),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _expanded ? 'Tampilan minggu' : 'Kalender lengkap',
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.view_week_outlined
                        : Icons.calendar_month_outlined,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TableCalendar(
                calendarFormat: _expanded
                    ? CalendarFormat.month
                    : CalendarFormat.week,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Bulan',
                  CalendarFormat.week: 'Minggu',
                },
                headerVisible: false,
                eventLoader: (day) =>
                    _dayEvents[DateFormat('yyyy-MM-dd').format(day)] ?? [],
                locale: 'en_US',
                focusedDay: _focusedDay,
                firstDay: DateTime(2010),
                lastDay: DateTime(2100, 12, 31),
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) {
                  _focusedDay = focused;
                  _loadEvents(selected);
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                  _loadEvents(focused);
                },
                rowHeight: 42,
                daysOfWeekHeight: 26,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  headerPadding: EdgeInsets.symmetric(vertical: 4),
                  leftChevronIcon: Icon(Icons.chevron_left, size: 22),
                  rightChevronIcon: Icon(Icons.chevron_right, size: 22),
                ),
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, day) => Center(
                    child: Text(
                      _monthLabel(day),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  dowBuilder: (context, day) {
                    const names = [
                      'Sen',
                      'Sel',
                      'Rab',
                      'Kam',
                      'Jum',
                      'Sab',
                      'Min',
                    ];
                    return Center(
                      child: Text(
                        names[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          color: day.weekday > 5
                              ? const Color(0xFF9E3434)
                              : const Color(0xFF73777D),
                        ),
                      ),
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  markersMaxCount: 3,
                  markerSize: 4,
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF3468AB),
                    shape: BoxShape.circle,
                  ),
                  cellMargin: const EdgeInsets.all(4),
                  defaultTextStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF24272B),
                  ),
                  weekendTextStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E3434),
                  ),
                  selectedTextStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22724C),
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFFE7F1EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Agenda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _focusedDay = DateTime.now();
                    _loadEvents(_focusedDay);
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Hari ini', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _dateLabel(_selectedDay),
              style: const TextStyle(fontSize: 12, color: Color(0xFF73777D)),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_failed)
            Center(
              child: TextButton.icon(
                onPressed: () => _loadEvents(_selectedDay),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            )
          else if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 28,
                    color: Color(0xFF8A8F95),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tidak ada agenda pada tanggal ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF73777D)),
                  ),
                ],
              ),
            )
          else
            ..._events.map(
              (event) => Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      width: 3,
                      color: _eventColor(event['color'].toString()),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 18,
                      color: _eventColor(event['color'].toString()),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        event['event']?.toString() ?? '',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
