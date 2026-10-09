import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';

class PopupProfile {
  PopupProfile._privateConstructor();
  static final instance = PopupProfile._privateConstructor();

  Future<void> showPopup(
    BuildContext context, {
    String data = '',
    Function? callback,
  }) async {
    final session = await AuthRepo.instance.getSession('user');
    if (!context.mounted) return;
    final name = session?['name']?.toString().trim() ?? '';
    final nrp = session?['email']?.toString() ?? '';
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(size.width - 260, top, 12, 0),
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 260),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Akun saya' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (nrp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'NRP $nrp',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF73777D),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Profil saya'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Color(0xFFB24343)),
              SizedBox(width: 12),
              Text('Keluar', style: TextStyle(color: Color(0xFFB24343))),
            ],
          ),
        ),
      ],
    );
    if (!context.mounted) return;
    if (action == 'profile') {
      await Navigator.of(context).pushNamed('/profile');
    } else if (action == 'logout') {
      await AuthRepo.instance.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
    callback?.call();
  }
}
