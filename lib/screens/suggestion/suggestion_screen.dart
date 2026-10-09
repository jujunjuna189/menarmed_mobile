import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/repository/suggestion_repo.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});
  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  Map _user = {};
  bool _sending = false;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    final value = await AuthRepo.instance.getSession('user');
    if (mounted) setState(() => _user = value is Map ? value : {});
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> onSend() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    ToastLoader.instance.showLoader();
    try {
      final success = await SuggestionRepo.instance.store({
        'from_id': _user['id']?.toString() ?? '-',
        'from_display': _user['name']?.toString() ?? '-',
        'message': _messageController.text.trim(),
      });
      if (mounted && success == true) _messageController.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Saran & Masukan')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Color(0xFF555B64)),
            ),
            title: Text(_user['name']?.toString() ?? 'Personil'),
            subtitle: const Text('Pengirim'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            minLines: 5,
            maxLines: 12,
            enabled: !_sending,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Pesan',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF383A3E)),
              ),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Pesan belum diisi'
                : null,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _sending ? null : onSend,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF383A3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(_sending ? 'Mengirim...' : 'Kirim'),
          ),
        ],
      ),
    ),
  );
}
