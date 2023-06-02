import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
  List _dashboardSlider = [];

  @override
  void initState() {
    super.initState();
    getFirstData();
  }

  void getFirstData() async {
    await getSlider();
    setState(() {});
  }

  Future getSlider() async {
    await FeatureRepo.instance.dashboardSlider({}).then((value) {
      _dashboardSlider = value;
    });
  }

  void alarmNavigation() async {
    AuthRepo.instance.getSession("user").then((value) {
      if (value['role'] == 1 || value['role'] == '1') {
        Navigator.of(context).pushNamed("/alarm");
      } else {
        ToastAlert.instance.showMessage(
            customMessage: true, customMessageText: "Hanya yang berwenang");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ScrollPhysics(),
      children: [
        const SizedBox(
          height: 25,
        ),
        _dashboardSlider.isNotEmpty
            ? CarouselSlider(
                items: _dashboardSlider.map((value) {
                  return Builder(builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            value['path'],
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    );
                  });
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                ),
              )
            : Container(),
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                    color: bgLightTransparent,
                    borderRadius: BorderRadius.circular(10)),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/note.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Absensi",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/soldier.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Perizinan",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/alarm.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Alarm Stelling",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/barracks.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Gudang Senjata",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              Navigator.of(context)
                                  .pushNamed("/vehicle_van_permission");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/armored-van.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Ranpur",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              Navigator.of(context)
                                  .pushNamed("/vehicle_permission");
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/armored-vehicle.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Angkutan",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/backpack.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Logistik",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/army.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Kemampuan",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          "assets/images/icon/identification-card.png")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Staff",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
