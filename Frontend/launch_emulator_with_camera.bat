@echo off
REM Launch Android emulator with webcam support for emotion detection app
echo Starting emulator with webcam support...
start "" "C:\Users\yassi\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd pixel2_api29 -camera-front webcam0 -camera-back webcam0
echo Emulator is starting... Please wait for it to boot completely before running 'flutter run'
