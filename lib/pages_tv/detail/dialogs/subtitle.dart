import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/player.dart';

import '../../../components/gap.dart';
import '../../../providers/user_config.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';
import '../../components/filled_button.dart';
import '../../components/keyboard_reopen.dart';
import '../../components/setting.dart';
import '../../components/text_button.dart';
import '../../utils/driver_file_picker.dart';

class SubtitleDialog extends StatefulWidget {
  const SubtitleDialog({super.key, this.subtitle});

  final SubtitleData? subtitle;

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
    return SettingPage(
      title: AppLocalizations.of(context)!.buttonSubtitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Form(
          key: _formKey,
          child: KeyboardReopen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open_rounded),
                      onPressed: () async {
                        final resp = await navigateTo(navigatorKey.currentContext!, const DriverFilePicker(selectableType: FileType.file));
                        if (resp is (int, DriverFile)) {
                          final file = resp.$2;
                          final ext = file.name.split('.').lastOrNull;
                          _mimeType = SubtitleMimeType.fromString(ext)?.name;
                          _filename = file.name;
                          _controller.text = 'driver://${resp.$1}/${file.id}';
                          setState(() {});
                        }
                      },
                    ),
                    hintText: widget.subtitle?.title?.toString(),
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
                      isDense: true,
                      labelText: AppLocalizations.of(context)!.subtitleFormItemLabelType,
                    ),
                    items: [
                      DropdownMenuItem(child: Text(AppLocalizations.of(context)!.formItemNotSelectedHint, style: Theme.of(context).textTheme.labelSmall)),
                      ...SubtitleMimeType.values.map((mime) => DropdownMenuItem(value: mime.name, child: Text(mime.name.toUpperCase())))
                    ],
                    validator: (value) => requiredValidator(context, value),
                    onChanged: (v) => setState(() => _mimeType = v)),
                Gap.vMD,
                DropdownButtonFormField(
                    value: _language,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.language),
                      isDense: true,
                      labelText: AppLocalizations.of(context)!.subtitleFormItemLabelLanguage,
                    ),
                    items: [
                      DropdownMenuItem(child: Text(AppLocalizations.of(context)!.formItemNotSelectedHint, style: Theme.of(context).textTheme.labelSmall)),
                      ...SystemLanguage.values.map((lang) => DropdownMenuItem(value: lang.name, child: Text(lang.name.toUpperCase())))
                    ],
                    onChanged: (v) => setState(() => _language = v)),
                const Spacer(),
                TVFilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _mimeType != null) {
                      Navigator.of(context).pop(SubtitleData(
                        url: _controller.text,
                        mimeType: _mimeType,
                        language: _language,
                        title: _filename,
                      ));
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.buttonConfirm),
                ),
                TVTextButton(
                  onPressed: () => Navigator.pop(context, SubtitleData.empty),
                  child: Text(AppLocalizations.of(context)!.buttonReset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
