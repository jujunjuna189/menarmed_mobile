import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/repository/feature_repo.dart';
import 'package:menarmed_mobile/utils/colors.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _textMarquee = "Selamat Datang Di Aplikasi Menarmed";
  List _dashboardSlider = [];
  int _sliderIndex = 0;

  @override
  void initState() {
    super.initState();
    getFirstData();
  }

  void getFirstData() async {
    await getTextMarque();
    await getSlider();
    if (!mounted) return;
    for (final slide in _dashboardSlider) {
      precacheImage(NetworkImage(slide['path']), context, onError: (error, stack) {});
    }
    if (mounted) setState(() {});
  }

  Future getTextMarque() async {
    await FeatureRepo.instance.dashboardTextMarquee({}).then((value) {
      if (value is List && value.isNotEmpty) {
        _textMarquee = value.first['text']?.toString() ?? _textMarquee;
      }
    });
  }

  Future getSlider() async {
    await FeatureRepo.instance.dashboardSlider({}).then((value) {
      _dashboardSlider = value is Iterable ? value.toList() : [];
    });
  }

  void alarmNavigation() async {
    AuthRepo.instance.getSession("user").then((value) {
      if (value['role'] == 1 || value['role'] == '1') {
        Navigator.of(context).pushNamed("/alarm");
      } else {
        ToastAlert.instance.showMessage(customMessage: true, customMessageText: "Hanya yang berwenang");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: const BoxDecoration(
            color: bgLightTransparent,
          ),
          child: SizedBox(
            height: 40.0,
            child: Marquee(
              text: " $_textMarquee",
              style: const TextStyle(fontWeight: FontWeight.bold),
              scrollAxis: Axis.horizontal,
            ),
          ),
        ),
        _dashboardSlider.isNotEmpty
            ? Column(children: [
              CarouselSlider(
                items: _dashboardSlider.map((value) {
                  return Builder(builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: Color(0xFFD5D5D5)),
                          Image.network(
                            value['path'],
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            loadingBuilder: (context, child, progress) => progress == null
                                ? child
                                : const ColoredBox(color: Color(0xFFD5D5D5), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                            errorBuilder: (context, error, stack) => const ColoredBox(
                              color: Color(0xFFD5D5D5),
                              child: Center(child: Icon(Icons.broken_image_outlined, size: 28, color: Color(0xFF73777D))),
                            ),
                          ),
                        ],
                      ),
                      ),
                    );
                  });
                }).toList(),
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.94,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: _dashboardSlider.length > 1,
                  autoPlay: _dashboardSlider.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) => setState(() => _sliderIndex = index),
                ),
              ),
              if (_dashboardSlider.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Wrap(
                    spacing: 4,
                    children: List.generate(_dashboardSlider.length, (index) => Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _sliderIndex ? const Color(0xFF252525) : const Color(0xFFBFC3C7),
                      ),
                    )),
                  ),
                ),
            ])
            : Container(),
        const SizedBox(
          height: 5,
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(color: bgLightTransparent, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/presence");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(width: 40, height: 40, child: Image.asset("assets/images/icon/note.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Absensi",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Keterangan Personil",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/permission");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(width: 40, height: 40, child: Image.asset("assets/images/icon/soldier.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Perizinan",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Keluar Masuk Ksatrian",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              alarmNavigation();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(width: 40, height: 40, child: Image.asset("assets/images/icon/alarm.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Alarm Stelling",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Sirine Kesiapsiagaan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/armory");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40, height: 40, child: Image.asset("assets/images/icon/barracks.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Gudang Senjata",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Keluar Masuk Senjata",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/vehicle_van_permission");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40, height: 40, child: Image.asset("assets/images/icon/armored-van.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Ranpur",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Keluar Masuk Kendaraan Tempur",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/vehicle_permission");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset("assets/images/icon/armored-vehicle.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Angkutan",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Keluar Masuk Angkutan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/logistics");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40, height: 40, child: Image.asset("assets/images/icon/backpack.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Logistik",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Pembagian Kaporlap",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/ability_data");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(width: 40, height: 40, child: Image.asset("assets/images/icon/army.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Kemampuan",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Data Kemampuan Personil",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/staff");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset("assets/images/icon/identification-card.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Staff",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Data Staff",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.of(context).pushNamed("/suggestion");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40, height: 40, child: Image.asset("assets/images/icon/letterbox.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Saran & Masukan",
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Text(
                                    "Kirim Saran dan Masukan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
