import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/connect_button.dart';
import '../../components/form_group.dart';
import '../../utils/notification.dart';
import '../../validators/validators.dart';

class LiveEditPage extends StatefulWidget {
  final Playlist? item;

  const LiveEditPage({super.key, this.item});

  @override
  State<LiveEditPage> createState() => _LiveEditPageState();
}

class _LiveEditPageState extends State<LiveEditPage> {
  late final _formGroup = FormGroupController([
    FormItem(
      'title',
      labelText: AppLocalizations.of(context)!.liveCreateFormItemLabelTitle,
      prefixIcon: Icons.live_tv,
      validator: (value) => requiredValidator(context, value),
      value: widget.item?.title,
    ),
    FormItem(
      'url',
      labelText: AppLocalizations.of(context)!.liveCreateFormItemLabelUrl,
      helperText: AppLocalizations.of(context)!.liveCreateFormItemHelperUrl,
      prefixIcon: Icons.link,
      validator: (value) => urlValidator(context, value, true),
      value: widget.item?.url,
    ),
  ]);

  @override
  void dispose() {
    _formGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? AppLocalizations.of(context)!.pageTitleAdd : AppLocalizations.of(context)!.pageTitleEdit),
        actions: [
          ConnectButton(onData: onConnectData),
          IconButton(icon: const Icon(Icons.check), onPressed: onSubmit),
        ],
      ),
      body: FormGroup(controller: _formGroup),
    );
  }

  onSubmit() async {
    if (_formGroup.validate()) {
      if (widget.item == null) {
        await showNotification(context, Api.playlistInsert(_formGroup.data));
      } else {
        await showNotification(context, Api.playlistUpdateById({..._formGroup.data, 'id': widget.item?.id}));
      }
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  onConnectData(String data) {
    final focusedItem = _formGroup.focusedItem;
    if (focusedItem != null) {
      focusedItem.controller.text += data;
    }
  }
}
