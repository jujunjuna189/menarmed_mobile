import 'package:audioplayers/audioplayers.dart';
import 'package:menarmed_mobile/model/alarm_description_model.dart';
import 'package:menarmed_mobile/repository/firebase/fire_alarm_repo.dart';
import 'package:menarmed_mobile/repository/notification_repo.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';

class FireBackground {
  FireBackground._privateContructor();
  static final FireBackground instance = FireBackground._privateContructor();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool _alarmActive = false;

  void initialized() {
    alarmStelling();
  }

  void alarmStelling() async {
    FireAlarmRepo.instance.onChange(
      callback: ((value) {
        final active = value is Map && value['status'] == true;
        final siren = active && value['siren'] != false;
        if (siren && !isPlaying) {
          initializedAudio(audioPlayer);
          isPlaying = true;
        } else if (!siren && isPlaying) {
          stopAudio(audioPlayer);
          isPlaying = false;
        }
        if (active && !_alarmActive) {
          final code = int.tryParse(value['code'].toString());
          final alarms = AlarmDescriptionModel.instance.alarmDescription;
          if (code != null && code >= 0 && code < alarms.length) {
            NotificationRepo.instance.setNotif(
              title: alarms[code]['title'],
              subTitle: alarms[code]['sub_title'],
              content: alarms[code]['description'],
              code: '0-alarm',
            );
          }
        }
        _alarmActive = active;
      }),
    );
  }

  void initializedAudio(AudioPlayer audioPlayer) async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource("audio/alarm.mp3"));
    ToastAlert.instance.showMessage(
      customMessage: true,
      customMessageText: "Alarm dibunyikan",
    );
  }

  void stopAudio(AudioPlayer audioPlayer) async {
    await audioPlayer.stop();
    ToastAlert.instance.showMessage(
      customMessage: true,
      customMessageText: "Alarm diberhentikan",
    );
  }
}
