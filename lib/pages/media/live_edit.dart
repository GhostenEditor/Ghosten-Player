import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/form_group.dart';
import '../../utils/notification.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';

class LiveEditPage extends StatefulWidget {
  final Playlist? item;

  const LiveEditPage({super.key, this.item});

  @override
  State<LiveEditPage> createState() => _LiveEditPageState();
}

class _LiveEditPageState extends State<LiveEditPage> {
  late final _controller = TextEditingController(text: widget.item?.url);
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
      suffixIcon: IconButton(
        icon: const Icon(Icons.folder_open_rounded),
        onPressed: () async {
          final res = await showDriverFilePicker(context, AppLocalizations.of(context)!.titleEditSubtitle, selectableType: FileType.file);
          if (res != null) {
            final file = res.$2;
            _controller.text = 'driver://${res.$1}/${file.id}';
            setState(() {});
          }
        },
      ),
      controller: _controller,
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
          IconButton(icon: const Icon(Icons.check), onPressed: () => onSubmit(context)),
        ],
      ),
      body: FormGroup(controller: _formGroup),
    );
  }

  onSubmit(BuildContext context) async {
    if (_formGroup.validate()) {
      if (widget.item == null) {
        final resp = await showNotification(context, Api.playlistInsert(_formGroup.data));
        if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
      } else {
        final resp = await showNotification(context, Api.playlistUpdateById({..._formGroup.data, 'id': widget.item?.id}));
        if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
      }
    }
  }
}
