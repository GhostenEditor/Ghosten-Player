import 'dart:async';

import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/async_image.dart';
import '../components/error_message.dart';
import '../components/focus_card.dart';
import '../components/future_builder_handler.dart';
import '../components/gap.dart';
import '../components/no_data.dart';
import '../components/scrollbar.dart';
import '../pages/account/account_login.dart';
import '../platform_api.dart';
import '../providers/user_config.dart';

const _lightSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarIconBrightness: Brightness.dark,
  // 设置为全透明时，在某些设备上NavigationBar并不会完全透明
  systemNavigationBarColor: Color(0x01FFFFFF),
  statusBarIconBrightness: Brightness.dark,
  statusBarColor: Colors.transparent,
);

const _darkSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarIconBrightness: Brightness.light,
  // 设置为全透明时，在某些设备上NavigationBar并不会完全透明
  systemNavigationBarColor: Color(0x01000000),
  statusBarIconBrightness: Brightness.light,
  statusBarColor: Colors.transparent,
);

SystemUiOverlayStyle? getSystemUiOverlayStyle(BuildContext context, [ThemeMode mode = ThemeMode.system]) {
  switch (mode) {
    case ThemeMode.system:
      return switch (context.watch<UserConfig>().themeMode) {
        ThemeMode.light => _lightSystemUiOverlayStyle,
        ThemeMode.dark => _darkSystemUiOverlayStyle,
        ThemeMode.system => switch (MediaQuery.platformBrightnessOf(context)) {
            Brightness.light => _lightSystemUiOverlayStyle,
            Brightness.dark => _darkSystemUiOverlayStyle,
          },
      };
    case ThemeMode.light:
      return _lightSystemUiOverlayStyle;
    case ThemeMode.dark:
      return _darkSystemUiOverlayStyle;
  }
}

void setPreferredOrientations(bool fullscreen) {
  if (PlatformApi.isAndroidPhone()) {
    if (fullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
}

Future<T?> navigateTo<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(MaterialPageRoute(builder: (context) => page));
}

Future<T?> navigateToSlideUp<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ));
}

extension DateTimeExtension on DateTime {
  String format() {
    return formatDate(this, [yyyy, '-', mm, '-', dd]);
  }

  String formatFull() {
    return formatDate(this, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }

  String formatFullWithoutSec() {
    return formatDate(this, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }

  Duration fromNow() {
    return Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - millisecondsSinceEpoch);
  }

  operator >=(DateTime other) {
    return microsecondsSinceEpoch >= other.microsecondsSinceEpoch;
  }

  operator >(DateTime other) {
    return microsecondsSinceEpoch > other.microsecondsSinceEpoch;
  }

  operator <=(DateTime other) {
    return microsecondsSinceEpoch <= other.microsecondsSinceEpoch;
  }

  operator <(DateTime other) {
    return microsecondsSinceEpoch < other.microsecondsSinceEpoch;
  }
}

extension IntExtension on int {
  String toSizeDisplay() {
    return switch (this) {
      < 1 << 10 => '$this B',
      < 1 << 20 => '${double.parse((this / (1 << 10)).toStringAsFixed(2))} KB',
      < 1 << 30 => '${double.parse((this / (1 << 20)).toStringAsFixed(2))} MB',
      _ => '${double.parse((this / (1 << 30)).toStringAsFixed(2))} GB',
    };
  }

  String toNetworkSpeed() {
    return '${toSizeDisplay()}/s';
  }
}

extension DurationExtension on Duration {
  String fromNowFormat(BuildContext context) {
    if (isNegative) {
      return '-${(this * -1).fromNowFormat(context)}';
    }
    if (inDays > 0) {
      final inYears = (inDays / 365).floor();
      final inMonths = (inDays / 30).floor();
      if (inYears > 0) {
        return AppLocalizations.of(context)!.unitYear(inYears);
      } else if (inMonths > 0) {
        return AppLocalizations.of(context)!.unitMonth(inMonths);
      } else {
        return AppLocalizations.of(context)!.unitDay(inDays);
      }
    } else if (inHours > 0) {
      return AppLocalizations.of(context)!.unitHour(inHours);
    } else if (inMinutes > 0) {
      return AppLocalizations.of(context)!.unitMinute(inMinutes);
    } else {
      return AppLocalizations.of(context)!.unitSecond(inSeconds);
    }
  }

  String toDisplay() {
    if (inHours > 0) {
      return '$inHours:${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }
}

extension UriExtension on Uri {
  Uri normalize() {
    if (scheme.toLowerCase() == 'file') {
      return this;
    } else {
      return replace(
        scheme: scheme.isEmpty ? Api.baseUrl.scheme : null,
        host: host.isEmpty ? Api.baseUrl.host : null,
        port: port == 0 ? Api.baseUrl.port : null,
      );
    }
  }
}

Future<(int, DriverFile)?> showDriverFilePicker(
  BuildContext context,
  String title, {
  FileType? fileType,
  FileType? selectableType,
}) {
  return showModalBottomSheet<(int, DriverFile)>(
      context: context,
      elevation: 0,
      constraints: const BoxConstraints(minWidth: double.infinity),
      builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.titleSelectAnAccount, style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(
                    height: 250,
                    child: StatefulBuilder(builder: (context, setState) {
                      return FutureBuilderHandler<List<DriverAccount>>(
                          future: Api.driverQueryAll(),
                          builder: (context, snapshot) {
                            return ScrollbarListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: snapshot.requireData.length + 2,
                                itemBuilder: (context, index) {
                                  if (index == snapshot.requireData.length + 1) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: IconButton.filledTonal(
                                          autofocus: PlatformApi.isAndroidTV() && index == 0,
                                          onPressed: () async {
                                            final flag = await navigateTo<bool>(context, const AccountLoginPage());
                                            if (flag == true) setState(() {});
                                          },
                                          icon: const Icon(Icons.add),
                                        ),
                                      ),
                                    );
                                  } else if (index == snapshot.requireData.length) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: IconButton.filledTonal(
                                          autofocus: PlatformApi.isAndroidTV() && index == 0,
                                          onPressed: () async {
                                            await Api.requestStoragePermission();
                                            final defaultPath = await FilePicker.externalStoragePath ?? '/';
                                            if (!context.mounted) return;
                                            final file = await _showFilePicker(context,
                                                title: title,
                                                type: FilePickerType.local,
                                                driverId: 0,
                                                defaultPath: defaultPath,
                                                fileType: fileType,
                                                selectableType: selectableType);
                                            if (file != null) {
                                              if (context.mounted) Navigator.of(context).pop((0, file));
                                            }
                                          },
                                          icon: const Icon(Icons.folder_open),
                                        ),
                                      ),
                                    );
                                  } else {
                                    final item = snapshot.requireData[index];
                                    return FocusCard(
                                      width: 160,
                                      autofocus: PlatformApi.isAndroidTV() && index == 0,
                                      onTap: () async {
                                        final file = await _showFilePicker(
                                          context,
                                          title: title,
                                          type: FilePickerType.remote,
                                          driverId: item.id,
                                          defaultPath: '/',
                                          fileType: fileType,
                                          selectableType: selectableType,
                                        );
                                        if (file != null) {
                                          if (context.mounted) Navigator.of(context).pop((item.id, file));
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          item.avatar == null
                                              ? const Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Icon(Icons.account_circle, size: 120),
                                                )
                                              : AsyncImage(
                                                  item.avatar!,
                                                  ink: true,
                                                  width: 160,
                                                  height: 160,
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(item.name, overflow: TextOverflow.ellipsis),
                                                  Text(AppLocalizations.of(context)!.driverType(item.type.name)),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                });
                          });
                    }),
                  ),
                ],
              ),
            ),
          ),
      isScrollControlled: true);
}

Future<DriverFile?> _showFilePicker(
  BuildContext context, {
  required String title,
  required FilePickerType type,
  required int driverId,
  required String defaultPath,
  FileType? fileType,
  FileType? selectableType,
}) {
  return FilePicker.showFilePicker(context,
      type: type,
      title: title,
      errorBuilder: (snapshot) => Center(child: ErrorMessage(snapshot: snapshot)),
      empty: const NoData(),
      onFetch: (item) => Api.fileList(driverId, item?.id ?? defaultPath, type: fileType),
      childBuilder: (context, item, {required onPage, required onSubmit, required onRefresh, groupValue}) {
        return Focus(
          onKeyEvent: item.type == FileType.folder
              ? (FocusNode node, KeyEvent event) {
                  if (event is KeyUpEvent) {
                    switch (event.logicalKey) {
                      case LogicalKeyboardKey.arrowRight:
                        onPage();
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.select:
                      case LogicalKeyboardKey.enter:
                        onSubmit(item);
                        return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                }
              : null,
          child: ListTile(
            leading: Radio(value: item, onChanged: (selectableType == null || item.type == selectableType) ? onSubmit : null, groupValue: groupValue),
            title: Text(item.name),
            subtitle: RichText(
                text: TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
              if (item.updatedAt != null) TextSpan(text: item.updatedAt!.formatFull()),
              if (item.updatedAt != null) const WidgetSpan(child: Gap.hMD),
              if (item.size != null) TextSpan(text: item.size!.toSizeDisplay()),
            ])),
            trailing: item.type == FileType.folder
                ? IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onPage,
                  )
                : null,
            onTap: item.type == FileType.folder ? onPage : null,
          ),
        );
      });
}
