import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/async_image.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/list_tile.dart';
import '../settings/settings_login.dart';
import 'utils.dart';

class DriverFilePicker extends StatefulWidget {
  const DriverFilePicker({super.key, this.fileType, this.selectableType});

  final FileType? fileType;
  final FileType? selectableType;

  @override
  State<DriverFilePicker> createState() => _DriverFilePickerState();
}

class _DriverFilePickerState extends State<DriverFilePicker> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _selectedDriverId = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _selectedDriverId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              children: [
                AppBar(
                  title: Text(AppLocalizations.of(context)!.titleSelectAnAccount),
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: FutureBuilderHandler<List<DriverAccount>>(
                    future: Api.driverQueryAll(),
                    builder:
                        (context, snapshot) => ListenableBuilder(
                          listenable: _selectedDriverId,
                          builder: (context, _) {
                            return ListView(
                              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                              children: [
                                ...snapshot.requireData.indexed.map(
                                  (entry) => TVListTile(
                                    selected: _selectedDriverId.value == entry.$2.id,
                                    autofocus: entry.$1 == 0,
                                    title: Text(entry.$2.name),
                                    subtitle: Text(AppLocalizations.of(context)!.driverType(entry.$2.type.name)),
                                    leading: AspectRatio(
                                      aspectRatio: 1,
                                      child:
                                          entry.$2.avatar == null
                                              ? const AspectRatio(
                                                aspectRatio: 1,
                                                child: Icon(Icons.account_circle, size: 48),
                                              )
                                              : AsyncImage(
                                                entry.$2.avatar!,
                                                radius: BorderRadius.circular(6),
                                                ink: true,
                                              ),
                                    ),
                                    onTap: () async {
                                      _selectedDriverId.value = entry.$2.id;
                                      navigateToSlideLeft(
                                        _navigatorKey.currentContext!,
                                        _FileListPage(
                                          driverId: entry.$2.id,
                                          parentFileId: '/',
                                          type: widget.fileType,
                                          selectableType: widget.selectableType,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TVIconButton.filledTonal(
                                      onPressed: () async {
                                        await Api.requestStoragePermission();
                                        final defaultPath = await FilePicker.externalStoragePath ?? '/';
                                        if (!context.mounted) return;
                                        navigateToSlideLeft(
                                          _navigatorKey.currentContext!,
                                          _FileListPage(
                                            driverId: 0,
                                            parentFileId: defaultPath,
                                            type: widget.fileType,
                                            selectableType: widget.selectableType,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.folder_open),
                                    ),
                                    TVIconButton(
                                      autofocus: snapshot.requireData.isEmpty,
                                      onPressed: () async {
                                        final flag = await navigateTo<bool>(
                                          navigatorKey.currentContext!,
                                          const SettingsLoginPage(),
                                        );
                                        if (flag ?? false) setState(() {});
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Flexible(
            flex: 3,
            child: Actions(
              actions: {
                DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                  onInvoke: (indent) {
                    final currentNode = FocusManager.instance.primaryFocus;
                    if (currentNode != null) {
                      final nearestScope = currentNode.nearestScope!;
                      final focusedChild = nearestScope.focusedChild;
                      if (focusedChild == null || !focusedChild.focusInDirection(indent.direction)) {
                        switch (indent.direction) {
                          case TraversalDirection.left:
                            nearestScope.parent?.focusInDirection(indent.direction);
                          default:
                        }
                      }
                    }
                    return null;
                  },
                ),
              },
              child: NavigatorPopHandler(
                onPopWithResult: (_) {
                  _navigatorKey.currentState!.maybePop();
                },
                child: Navigator(
                  key: _navigatorKey,
                  requestFocus: false,
                  onGenerateRoute:
                      (settings) => FadeInPageRoute(builder: (context) => const SizedBox(), settings: settings),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileListPage extends StatefulWidget {
  const _FileListPage({
    required this.driverId,
    required this.parentFileId,
    this.type,
    this.category,
    this.selectableType,
  });

  final int driverId;
  final String parentFileId;
  final FileType? type;
  final String? category;
  final FileType? selectableType;

  @override
  State<_FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<_FileListPage> {
  DriverFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FutureBuilderHandler(
        future: Api.fileList(widget.driverId, widget.parentFileId, type: widget.type),
        builder: (context, snapshot) {
          return snapshot.requireData.isNotEmpty
              ? ListView.builder(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  return Focus(
                    skipTraversal: true,
                    onKeyEvent:
                        item.type == FileType.folder
                            ? (FocusNode node, KeyEvent event) {
                              if (event is KeyUpEvent) {
                                switch (event.logicalKey) {
                                  case LogicalKeyboardKey.arrowRight:
                                    _onPage(item.id);
                                    return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            }
                            : null,
                    child: TVListTile(
                      autofocus: index == 0,
                      leading: Radio(
                        value: item,
                        onChanged:
                            (widget.selectableType == null || item.type == widget.selectableType)
                                ? (file) => Navigator.of(navigatorKey.currentContext!).pop((widget.driverId, item))
                                : null,
                        groupValue: _selectedFile,
                      ),
                      title: Text(item.name),
                      subtitle: Row(
                        spacing: 12,
                        children: [
                          if (item.updatedAt != null) Text(item.updatedAt!.formatFull()),
                          if (item.size != null) Text(item.size!.toSizeDisplay()),
                        ],
                      ),
                      trailing:
                          item.type == FileType.folder
                              ? TVIconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _onPage(item.id))
                              : null,
                      onTap:
                          (widget.selectableType == null || item.type == widget.selectableType)
                              ? () => Navigator.of(navigatorKey.currentContext!).pop((widget.driverId, item))
                              : () {},
                    ),
                  );
                },
              )
              : const NoData();
        },
      ),
    );
  }

  void _onPage(String parentFileId) {
    navigateToSlideLeft(
      context,
      _FileListPage(
        driverId: widget.driverId,
        parentFileId: parentFileId,
        type: widget.type,
        category: widget.category,
        selectableType: widget.selectableType,
      ),
    );
  }
}
