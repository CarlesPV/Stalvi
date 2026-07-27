#!/bin/bash
set -e

# Detectar argumentos
CLEAN=false
BUILD=false

for arg in "$@"; do
  if [ "$arg" == "--clean" ] || [ "$arg" == "-c" ]; then
    CLEAN=true
  elif [ "$arg" == "--build" ] || [ "$arg" == "-b" ]; then
    BUILD=true
  fi
done

if [ "$CLEAN" = true ]; then
  echo "🧹 Limpiando proyecto..."
  flutter clean
  flutter pub get
fi

if [ "$BUILD" = true ] || [ "$CLEAN" = true ]; then
  echo "⚙️ Generando código con build_runner..."
  dart run build_runner build
fi

echo "✨ Formateando y analizando..."
dart format .
flutter analyze --fatal-warnings --fatal-infos

echo "🚀 Lanzando en el dispositivo..."
flutter run -d 25ba202f