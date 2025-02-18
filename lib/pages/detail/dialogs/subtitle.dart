import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/player.dart';

import '../../../components/gap.dart';
import '../../../providers/user_config.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';

class SubtitleDialog extends StatefulWidget {
  final SubtitleData? subtitle;

  const SubtitleDialog({super.key, this.subtitle});

  @override
  State<SubtitleDialog> createState() => _SubtitleDialogState();
}

class _SubtitleDialogState extends State<SubtitleDialog> {
  final _controller = TextEditingController();
  String? _mimeType;
  String? _language;
  String? _filename;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.buttonSubtitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open_rounded),
                  onPressed: () async {
                    final res = await showDriverFilePicker(context, AppLocalizations.of(context)!.titleEditSubtitle, selectableType: FileType.file);
                    if (res != null) {
                      final file = res.$2;
                      final ext = file.name.split('.').lastOrNull;
                      _mimeType = SubtitleMimeType.fromString(ext)?.name;
                      _filename = file.name;
                      _controller.text = 'driver://${res.$1}/${file.id}';
                      setState(() {});
                    }
                  },
                ),
                hintText: widget.subtitle?.title?.toString(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.subtitleFormItemLabelUrl,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () {
                final value = _controller.text;
                if (value.startsWith(RegExp(r'^http(s)://'))) {
                  final ext = value.split('.').lastOrNull;
                  _mimeType = SubtitleMimeType.fromString(ext)?.name;
                  _filename = null;
                  setState(() {});
                }
                FocusScope.of(context).nextFocus();
              },
            ),
            Gap.vMD,
            DropdownButtonFormField(
                value: _mimeType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.subtitles_outlined),
                  filled: true,
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.subtitleFormItemLabelType,
                ),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(AppLocalizations.of(context)!.formItemNotSelectedHint, style: Theme.of(context).textTheme.labelSmall)),
                  ...SubtitleMimeType.values.map((mime) => DropdownMenuItem(value: mime.name, child: Text(mime.name.toUpperCase())))
                ],
                validator: (value) => requiredValidator(context, value),
                onChanged: (v) => setState(() => _mimeType = v)),
            Gap.vMD,
            DropdownButtonFormField(
                value: _language,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.language),
                  filled: true,
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.subtitleFormItemLabelLanguage,
                ),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(AppLocalizations.of(context)!.formItemNotSelectedHint, style: Theme.of(context).textTheme.labelSmall)),
                  ...SystemLanguage.values.map((lang) => DropdownMenuItem(value: lang.name, child: Text(lang.name.toUpperCase())))
                ],
                onChanged: (v) => setState(() => _language = v)),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _mimeType != null) {
              Navigator.of(context).pop(SubtitleData(
                url: Uri.parse(_controller.text),
                mimeType: _mimeType!,
                language: _language,
                title: _filename,
              ));
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, SubtitleData.empty),
          child: Text(AppLocalizations.of(context)!.buttonReset),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
      ],
    );
  }
}
