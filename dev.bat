@echo off

wt ^
    new-tab --startingDirectory . cmd /k "dart run build_runner watch" ; ^
    split-pane --startingDirectory . cmd /k "flutter run --dart-define-from-file=.env"