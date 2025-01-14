import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../validators/validators.dart';
import '../components/input_assistance.dart';
import '../components/stepper_form.dart';
import '../utils/notification.dart';

class LiveEdit extends StatefulWidget {
  final Playlist? item;

  const LiveEdit({super.key, this.item});

  @override
  State<LiveEdit> createState() => _LiveEditState();
}

class _LiveEditState extends State<LiveEdit> {
  late final items = [
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
      validator: (value) => urlValidator(context, value, true),
      value: widget.item?.url,
    ),
  ];

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
                  image: DecorationImage(image: AssetImage('assets/images/bg-wheat.webp'), repeat: ImageRepeat.repeat),
                ),
                child: InputAssistance(onData: (data) {
                  final ctx = FocusManager.instance.primaryFocus?.context;
                  final textField = ctx?.findAncestorWidgetOfExactType<TextField>();
                  if (textField?.controller != null) {
                    textField!.controller!.text += data;
                  }
                }),
              )),
          Flexible(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.item == null ? AppLocalizations.of(context)!.pageTitleAdd : AppLocalizations.of(context)!.pageTitleEdit,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                  StepperForm(
                    items: items,
                    onComplete: (data) async {
                      if (widget.item == null) {
                        await showNotification(context, Api.playlistInsert(data));
                      } else {
                        await showNotification(context, Api.playlistUpdateById({...data, 'id': widget.item?.id}));
                      }
                      if (context.mounted) Navigator.of(context).pop(true);
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
