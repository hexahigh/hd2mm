#!/bin/bash

flutter clean
flutter pub get
dart run build_runner build
flutter build linux --release --dart-define-from-file=.env