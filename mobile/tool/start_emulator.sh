#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tool/env.sh
if ! emulator -list-avds | rg -qx focusmood; then
  echo no | avdmanager create avd --name focusmood --package 'system-images;android-35;default;x86_64' --device pixel_6
fi
if ! adb devices | rg -q '^emulator-[0-9]+[[:space:]]+(device|offline)'; then
  mood_accel=off
  if [[ -r /dev/kvm && -w /dev/kvm ]]; then mood_accel=on; fi
  mood_window=(-no-window)
  if [[ "${MOOD_EMULATOR_WINDOW:-0}" == 1 ]]; then mood_window=(); fi
  nohup emulator -avd focusmood "${mood_window[@]}" -no-audio -no-boot-anim -gpu swiftshader -accel "$mood_accel" -memory 2048 -cores 2 > /tmp/mood-emulator.log 2>&1 < /dev/null &
  echo "$!" > /tmp/mood-emulator.pid
fi
printf 'Emulador focusmood iniciado o ya disponible. Sin KVM el arranque tarda varios minutos.\n'
adb devices
printf 'Comprueba el arranque con: adb -e shell getprop sys.boot_completed (debe devolver 1).\n'
