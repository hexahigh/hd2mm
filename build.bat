@echo off

call flutter clean
call flutter pub get
call dart run build_runner build
call flutter build windows --release --dart-define-from-file=.env