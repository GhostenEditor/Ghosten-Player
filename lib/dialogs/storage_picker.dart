import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Scrollbar;
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/navigator.dart';
import '../adaptive/adaptive.dart';
import '../providers/function.dart';

class StoragePickDialog extends StatelessWidget {
  const StoragePickDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.of(context)!.titleSelectAnAccount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 230,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scrollbar(
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            if (function.settingsStorage)
                              FutureBuilderSliverHandler(
                                future: Api.storageQueryAll(),
                                errorBuilder: (context, snapshot) => SliverToBoxAdapter(
                                  child: SizedBox(width: 200, child: ErrorMessage(error: snapshot.error)),
                                ),
                                loading: const Padding(
                                  padding: EdgeInsets.only(right: 28),
                                  child: ImageCardPlaceholder(size: Size(160, 160)),
                                ),
                                builder: (context, snapshot) => SliverPadding(
                                  padding: snapshot.requireData.isNotEmpty ? const EdgeInsets.only(right: 28) : .zero,
                                  sliver: SliverList.separated(
                                    itemCount: snapshot.requireData.length,
                                    itemBuilder: (context, index) {
                                      final Storage item = snapshot.requireData[index];
                                      return ImageCard(
                                        src: item.avatar,
                                        fit: .contain,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                        width: 160,
                                        height: 160,
                                        title: Text(item.name, overflow: TextOverflow.ellipsis),
                                        subtitle: Text(AppLocalizations.of(context)!.driverType(item.type.name)),
                                        onTap: () => Navigator.of(context).pop((item, '/')),
                                      );
                                    },
                                    separatorBuilder: (context, index) => Gap.hMD,
                                  ),
                                ),
                              ),
                            FutureBuilderSliverHandler(
                              future: FilePicker.externalUsbStorages(),
                              builder: (context, snapshot) {
                                return SliverList.builder(
                                  itemCount: snapshot.requireData!.length,
                                  itemBuilder: (context, index) {
                                    final UsbStorage item = snapshot.requireData![index];
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 72),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4,
                                          children: [
                                            const Text(''),
                                            IconButton.filledTonal(
                                              icon: Icon(_guessStorageTypeByDesc(item.desc)),
                                              onPressed: () async {
                                                if (await FilePicker.requestStorageManagePermission() &&
                                                    context.mounted) {
                                                  Navigator.of(context).pop((Storage.local(), item.path));
                                                }
                                              },
                                            ),
                                            Text(item.desc, style: Theme.of(context).textTheme.labelMedium),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 72),
                                  child: IconButton.filledTonal(
                                    onPressed: () async {
                                      if (await FilePicker.requestStorageManagePermission() && context.mounted) {
                                        Navigator.of(context).pop((Storage.local(), null));
                                      }
                                    },
                                    icon: const Icon(Icons.folder_open),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 72),
                                  child: IconButton.filledTonal(
                                    onPressed: () async {
                                      final Object? flag = await context.pushNamed(.settingsStorageAdd);
                                      if (flag == true) {
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _guessStorageTypeByDesc(String desc) {
    final String d = desc.toLowerCase();
    if (d.contains('usb')) {
      return Icons.usb_outlined;
    } else if (d.contains('sd')) {
      return Icons.sd_card_outlined;
    } else {
      return Icons.usb_outlined;
    }
  }
}
