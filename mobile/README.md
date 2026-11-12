# homiz

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Actualizar Flutter global en Windows

Este proyecto requiere Dart `^3.13.3` (Dart 3.13.3 o superior, pero menor que 4.0.0). Flutter incluye Dart, por lo que hay que actualizar la instalación global de Flutter; no cambies este requisito para evitar el error.

En PowerShell, primero comprueba qué instalación se ejecuta:

```powershell
where.exe flutter
```

En esta máquina la instalación detectada es `C:\Flutter\flutter`. Actualízala desde PowerShell:

```powershell
& 'C:\Flutter\flutter\bin\flutter.bat' channel stable
& 'C:\Flutter\flutter\bin\flutter.bat' upgrade
& 'C:\Flutter\flutter\bin\flutter.bat' --version
```

En la salida de `--version`, confirma que Dart sea `3.13.3` o superior. Si `where.exe flutter` muestra varias rutas, Windows usa primero la que aparece antes; actualiza la instalación que quieras usar y asegúrate de que su carpeta `bin` tenga prioridad en el `Path` de usuario o del sistema. Esto actualiza la instalación compartida por los proyectos que usan esa ruta, pero no otras copias de Flutter ni instalaciones administradas por herramientas como FVM.

Después, desde la raíz de este proyecto Flutter:

```powershell
Set-Location .\mobile
flutter pub get
```
