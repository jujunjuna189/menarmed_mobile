import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:menarmed_mobile/utils/colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey _globalKey = GlobalKey();
  QRViewController? qrController;
  Barcode? _result;
  bool _statusCamera = false;
  bool _statusFlashCamera = false;
  bool _statusFlipCamera = false;

  @override
  void initState() {
    resumeCameraOnLoad();
    super.initState();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void resumeCameraOnLoad() {
    Timer(const Duration(seconds: 1), () async {
      await qrController?.resumeCamera().then((value) => _statusCamera = true);
      setState(() {});
    });
  }

  void qrCodeScan(QRViewController qrController) {
    this.qrController = qrController;
    qrController.scannedDataStream.listen((qrcode) {
      _result = qrcode;
      qrController.pauseCamera().then((value) {
        Navigator.of(context).pop(jsonEncode(_result!.code));
      });
    });
  }

  void onFlashCamera() async {
    await qrController?.toggleFlash();
    if (_statusFlashCamera) {
      _statusFlashCamera = false;
    } else {
      _statusFlashCamera = true;
    }

    setState(() {});
  }

  void onFlipCamera() async {
    await qrController?.flipCamera();
    if (_statusFlipCamera) {
      _statusFlipCamera = false;
    } else {
      _statusFlipCamera = true;
    }

    setState(() {});
  }

  void onResumePauseCamera() async {
    if (_statusCamera) {
      await qrController?.pauseCamera().then((value) => _statusCamera = false);
    } else {
      await qrController?.resumeCamera().then((value) => _statusCamera = true);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: QRView(
            key: _globalKey,
            onQRViewCreated: qrCodeScan,
            overlay: QrScannerOverlayShape(
              borderColor: bgDanger,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: scanArea,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 100,
            margin: const EdgeInsets.symmetric(vertical: 40),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgLightTransparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (() {
                    onFlashCamera();
                  }),
                  child: _statusFlashCamera
                      ? const Icon(Icons.flash_off)
                      : const Icon(Icons.flash_on),
                ),
                GestureDetector(
                  onTap: (() {
                    onFlipCamera();
                  }),
                  child: _statusFlipCamera
                      ? const Icon(Icons.flip_camera_android, color: textDanger)
                      : const Icon(Icons.flip_camera_android),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 64),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: bgLightTransparent,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: _statusCamera ? 'Jeda kamera' : 'Lanjutkan kamera',
                  onPressed: onResumePauseCamera,
                  padding: const EdgeInsets.all(12),
                  iconSize: 32,
                  icon: Icon(
                    _statusCamera
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline_rounded,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }
}
