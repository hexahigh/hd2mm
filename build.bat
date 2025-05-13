@echo off

flutter clean
flutter pub get
dart run build_runner build
flutter build windows --release --dart-define-from-file=.env