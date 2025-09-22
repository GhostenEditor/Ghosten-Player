import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../components/input_assistance.dart';
import '../components/stepper_form.dart';
import '../utils/driver_file_picker.dart';
import '../utils/notification.dart';

class LiveEdit extends StatefulWidget {
  const LiveEdit({super.key, this.item});

  final Playlist? item;

  @override
  State<LiveEdit> createState() => _LiveEditState();
}

class _LiveEditState extends State<LiveEdit> {
  late final _controller = TextEditingController(text: widget.item?.url);
  late final _items = [
    FormItem(
      'title',
      labelText: AppLocalizations.of(context)!.liveCreateFormItemLabelTitle,
      prefixIcon: const Icon(Icons.live_tv),
      validator: (value) => requiredValidator(context, value),
      value: widget.item?.title,
    ),
    FormItem(
      'url',
      labelText: AppLocalizations.of(context)!.liveCreateFormItemLabelUrl,
      helperText: AppLocalizations.of(context)!.liveCreateFormItemHelperUrl,
      prefixIcon: const Icon(Icons.link),
      suffixIcon: IconButton(
        icon: const Icon(Icons.folder_open_rounded),
        onPressed: () async {
          final resp = await navigateTo(
            navigatorKey.currentContext!,
            const DriverFilePicker(selectableType: FileType.file),
          );
          if (resp is (int, DriverFile)) {
            final file = resp.$2;
            _controller.text = 'driver://${resp.$1}/${file.id}';
          }
        },
      ),
      controller: _controller,
      validator: (value) => urlValidator(context, value, true),
      value: widget.item?.url,
    ),
  ];

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/tv/images/bg-wheat.webp'), repeat: ImageRepeat.repeat),
              ),
              child: InputAssistance(
                onData: (data) {
                  final ctx = FocusManager.instance.primaryFocus?.context;
                  final textField = ctx?.findAncestorWidgetOfExactType<TextField>();
                  if (textField?.controller != null) {
                    textField!.controller!.text += data;
                  }
                },
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item == null
                      ? AppLocalizations.of(context)!.pageTitleAdd
                      : AppLocalizations.of(context)!.pageTitleEdit,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                StepperForm(
                  items: _items,
                  onComplete: (data) async {
                    if (widget.item == null) {
                      final resp = await showNotification(context, Api.playlistInsert(data));
                      if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                    } else {
                      final resp = await showNotification(
                        context,
                        Api.playlistUpdateById({...data, 'id': widget.item?.id}),
                      );
                      if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
