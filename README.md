# Menarmed Mobile

Aplikasi Flutter untuk mendukung operasional satuan Menarmed, meliputi absensi, perizinan, informasi personel, pembelajaran, laporan, alarm, dan pemindaian QR.

## Getting Started

Pastikan Flutter dan dependency platform sudah terpasang, lalu siapkan project:

```bash
flutter pub get
```

Referensi Flutter:

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter cookbook](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)

## Development Environment

- Flutter stable 3.38.9
- Dart 3.10.8
- Java 17
- CocoaPods 1.16.2
- Android Gradle Plugin 8.9.1
- Gradle 8.11.1

Versi Dart minimum project adalah 3.10.0. Gunakan Flutter stable 3.38.9 atau versi kompatibel yang lebih baru.

## Environment Configuration

Project membaca `API_BASE_URL` melalui `--dart-define-from-file`. URL wajib diakhiri dengan `/`.

Siapkan file environment lokal dari template:

```bash
cp .env.example .env
cp .env_dev.example .env_dev
cp .env_staging.example .env_staging
```

Konfigurasi bawaan:

- Production: `https://menarmed.hplbz18.com/`
- Development Android emulator: `http://10.0.2.2:8000/`
- Staging: ganti placeholder pada `.env_staging` dengan URL staging yang aktif

File `.env`, `.env_dev`, dan `.env_staging` tidak disimpan ke Git. Tanpa argumen environment, aplikasi menggunakan URL production sebagai fallback.

## Run Flutter With Environment

Run production:

```bash
flutter run --dart-define-from-file=.env
```

Run development:

```bash
flutter run --dart-define-from-file=.env_dev
```

Run staging:

```bash
flutter run --dart-define-from-file=.env_staging
```

## Build Android

Build production:

```bash
flutter build apk --release --dart-define-from-file=.env
flutter build appbundle --release --dart-define-from-file=.env
```

Build development:

```bash
flutter build apk --debug --dart-define-from-file=.env_dev
```

Build staging:

```bash
flutter build apk --release --dart-define-from-file=.env_staging
flutter build appbundle --release --dart-define-from-file=.env_staging
```

## Build iOS

Install CocoaPods dan tambahkan `ios/Runner/GoogleService-Info.plist` dari Firebase project sebelum menjalankan build iOS.

```bash
cd ios
pod install
cd ..
flutter build ipa --release --dart-define-from-file=.env
```

## Firebase

Konfigurasi Android berada di `android/app/google-services.json`. Untuk iOS, unduh `GoogleService-Info.plist` dari Firebase Console dan letakkan di `ios/Runner/GoogleService-Info.plist`.

Gunakan konfigurasi Firebase yang sesuai untuk setiap environment apabila development, staging, dan production memakai Firebase project yang berbeda.

## Android Release Signing

Buat upload keystore dan simpan credential di luar version control:

```bash
keytool -genkeypair -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties
```

Isi password pada `android/key.properties`, lalu build release:

```bash
flutter build appbundle --release --dart-define-from-file=.env
flutter build apk --release --dart-define-from-file=.env
```

Jika `android/key.properties` belum tersedia, build release lokal menggunakan debug signing dan tidak boleh digunakan untuk distribusi.

## Sinkronisasi Token FCM (Android)

Token FCM disimpan ke tabel backend `push_devices` setelah login/registrasi, saat token berubah, dan saat aplikasi dibuka atau kembali aktif. Endpoint `POST /api/push-device` memakai Bearer token Sanctum dan memperbarui token per `installation_id`. Endpoint `DELETE /api/push-device` melepas perangkat dari akun saat logout. Bila sinkronisasi gagal, aplikasi mencoba lagi pada login atau resume berikutnya. Logout offline tetap menghapus sesi lokal, tetapi pelepasan perangkat di server bisa gagal; login berikutnya mengaitkan perangkat ke akun yang baru.

Jalankan migrasi backend saat memasang perubahan ini di server lain:

```bash
php artisan migrate
```
