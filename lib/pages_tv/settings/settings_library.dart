import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/async_image.dart';
import '../../components/gap.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../mixins/update.dart';
import '../utils/driver_file_picker.dart';
import '../utils/notification.dart';

class LibraryManage extends StatefulWidget {
  final String title;
  final LibraryType type;

  const LibraryManage({super.key, required this.title, required this.type});

  @override
  State<LibraryManage> createState() => _LibraryManageState();
}

class _LibraryManageState extends State<LibraryManage> {
  bool refresh = false;
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: widget.title,
      child: FutureBuilderHandler<List<Library>>(
          initialData: const [],
          future: Api.libraryQueryAll(widget.type),
          builder: (context, snapshot) {
            return ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
              ...snapshot.requireData.indexed.map((entry) => SlidableSettingItem(
                    autofocus: entry.$1 == 0,
                    title: Text(entry.$2.filename),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: entry.$2.driverAvatar == null
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 24,
                              ),
                            )
                          : AsyncImage(
                              entry.$2.driverAvatar!,
                              radius: BorderRadius.circular(6),
                              ink: true,
                            ),
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.driverType(entry.$2.driverType.name)),
                        Gap.hSM,
                        Text(entry.$2.driverName, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    actions: [
                      TVIconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () => showNotification(context, Api.libraryRefreshById(entry.$2.id), showSuccess: false),
                      ),
                      TVIconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await showConfirm(
                              context, AppLocalizations.of(context)!.deleteConfirmText, AppLocalizations.of(context)!.deleteMediaGroupConfirmText);
                          if (confirmed == true) {
                            if (!context.mounted) return;
                            final resp = await showNotification(context, Api.libraryDeleteById(entry.$2.id));
                            if (resp?.error == null && context.mounted) {
                              setState(() {});
                              updateController.add(null);
                            }
                          }
                        },
                      ),
                    ],
                  )),
              if (snapshot.requireData.isNotEmpty) const DividerSettingItem(),
              const GapSettingItem(height: 12),
              IconButtonSettingItem(
                  icon: const Icon(Icons.add),
                  autofocus: snapshot.requireData.isEmpty,
                  onPressed: () async {
                    final resp = await navigateTo(navigatorKey.currentContext!, const DriverFilePicker(selectableType: FileType.folder));
                    if (resp is (int, DriverFile)) {
                      addLibrary(resp.$1, resp.$2);
                    }
                  }),
            ]);
          }),
    );
  }

  Future<void> addLibrary(int driverId, DriverFile file) async {
    final resp = await showNotification<bool>(context, Future(() async {
      final id = await Api.libraryInsert(
        type: widget.type,
        driverId: driverId,
        id: file.id,
        parentId: file.parentId,
        filename: file.name,
      );
      await Api.libraryRefreshById(id);
      return true;
    }));
    if (resp?.data == true) {
      setState(() => refresh = true);
    }
  }
}
