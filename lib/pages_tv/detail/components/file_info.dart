import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/future_builder_handler.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';

class FileInfoSection extends StatefulWidget {
  const FileInfoSection({super.key, required this.fileId});

  final String fileId;

  @override
  State<FileInfoSection> createState() => _FileInfoSectionState();
}

class _FileInfoSectionState extends State<FileInfoSection> {
  late final future = Api.fileInfo(widget.fileId);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: future,
      builder: (context, snapshot) {
        final item = snapshot.requireData;
        return Material(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DefaultTextStyle(
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              child: Table(
                border: TableBorder.all(width: 0, color: Colors.transparent),
                columnWidths: const <int, TableColumnWidth>{0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                        child: Text(AppLocalizations.of(context)!.filePropertyDriverType),
                      ),
                      Text(AppLocalizations.of(context)!.driverType(item.driverType.name)),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                        child: Text(AppLocalizations.of(context)!.filePropertyFilename),
                      ),
                      Text(item.filename),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                        child: Text(AppLocalizations.of(context)!.filePropertySize),
                      ),
                      Text(item.size.toSizeDisplay()),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                        child: Text(AppLocalizations.of(context)!.filePropertyCreateAt),
                      ),
                      Text(item.createdAt.formatFull()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
