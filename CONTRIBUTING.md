# How to Contribute

Thank you for your interest in Ghosten Player! This guide will help you understand how to contribute to the repository.

> [!WARNING]  
> The following documentation only covers key points in the development process.

## Setting Up the Development Environment

Install the Flutter SDK from the [download page](https://docs.flutter.dev/install/archive).

The Flutter SDK version must match the one used in the GitHub Action build; otherwise, the build may fail.  
Refer to: https://github.com/GhostenEditor/Ghosten-Player/blob/576d6c26d06f2fbc2bc2775dd72f003896af0904/.github/workflows/release.yml#L23

If you are new to Flutter, detailed installation instructions can be found in the [official documentation](https://docs.flutter.dev/install).

### Supported Devices

The app runs only on `arm` devices (including emulators) with Android version 6+.

## Starting the Project

Use `flutter run --flavor=mobile` for the mobile version and `flutter run --flavor=tv --target=lib/main_tv.dart` for the TV version.

### Data Preparation

Currently, mock data is not supported. You can add your own data by referring to the [Wiki](https://github.com/GhostenEditor/Ghosten-Player/wiki).

If you are using Windows as your development machine, it is recommended to create a WebDAV server using the built-in Internet Information Services (IIS).  
Then create a test directory inside it to simulate a real-world usage environment.  
[Reference documentation](https://learn.microsoft.com/en-us/iis/install/installing-publishing-technologies/installing-and-configuring-webdav-on-iis)

### Media Scraping

If you use [themoviedb](https://www.themoviedb.org) for scraping, you need to prepare an `api_key` and assign it as the default value for the following variable. It can also be passed via environment variables.  
See the [reference documentation](https://dart.dev/libraries/core/environment-declarations) for examples. If not provided, themoviedb scraping will be disabled.  
https://github.com/GhostenEditor/Ghosten-Player/blob/576d6c26d06f2fbc2bc2775dd72f003896af0904/lib/const.dart#L6

## Contribution Scope

Currently, only front-end contributions are supported, including UI, interaction, internationalization, etc. Player-related code has been moved to [this repository](https://github.com/GhostenEditor/Ghosten-Player-flutter-packages).

### Localization

Currently, only Simplified Chinese and English are supported. The English translation may not be very accurate. If you are a native English speaker or proficient in English, please help us improve the translations.

If you are a speaker of other languages, you can add new language translations.

Internationalization documentation: https://docs.flutter.dev/ui/internationalization  
The internationalization files are located in the [lib/l10n](https://github.com/GhostenEditor/Ghosten-Player/tree/dev/lib/l10n) directory.
