import 'package:flutter/material.dart';

class ReportEntry extends StatelessWidget {
  const ReportEntry({
    super.key,
    required this.data,
    this.armory = false,
    this.fullWidth = false,
  });
  final Map<String, dynamic> data;
  final bool armory;
  final bool fullWidth;

  String _value(String key) => data[key]?.toString() ?? '-';

  Widget _detail(String label, String value, {IconData? icon}) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: icon == null
              ? null
              : Icon(icon, size: 14, color: const Color(0xFF73777D)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF73777D)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF24272B),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _movement(String label, String time, IconData icon, String? unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: Icon(icon, size: 16, color: const Color(0xFF73777D)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF73777D)),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF24272B),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF73777D),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTimes = data.containsKey('keluar');
    final returned = _value('masuk') != '-' && _value('masuk').isNotEmpty;
    final name = _value(
      data.containsKey('user_name') ? 'user_name' : 'from_display',
    );
    final statusColor = returned
        ? const Color(0xFF22724C)
        : const Color(0xFF9E3434);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: fullWidth ? 16 : 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E4E7))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Color(0xFF555A60),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF24272B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _value('created_at'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF73777D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasTimes) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Icon(
                    returned ? Icons.check_circle_outline : Icons.schedule,
                    size: 14,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    returned
                        ? (armory ? 'Sudah dikembalikan' : 'Sudah masuk')
                        : (armory ? 'Belum dikembalikan' : 'Belum masuk'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Divider(height: 1, color: Color(0xFFEEF0F2)),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _movement(
                      armory ? 'Pengambilan' : 'Keluar',
                      _value('keluar'),
                      Icons.north_east,
                      armory ? 'Batrai: ${_value('batrai_keluar')}' : null,
                    ),
                  ),
                  const VerticalDivider(
                    width: 16,
                    thickness: 1,
                    color: Color(0xFFEEF0F2),
                  ),
                  Expanded(
                    child: _movement(
                      armory ? 'Pengembalian' : 'Masuk',
                      _value('masuk'),
                      Icons.south_west,
                      armory ? 'Batrai: ${_value('batrai_masuk')}' : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data.containsKey('jenis_kendaraan'))
            _detail('Jenis kendaraan', _value('jenis_kendaraan')),
          if (data.containsKey('tujuan')) _detail('Tujuan', _value('tujuan')),
          if (data.containsKey('ket'))
            _detail('Keterangan', _value('ket'), icon: Icons.notes_outlined),
          if (data.containsKey('message'))
            _detail('Saran & Masukan', _value('message')),
        ],
      ),
    );
  }
}
