import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../validators/validators.dart';

class EpisodeMetadata extends StatefulWidget {
  const EpisodeMetadata({super.key, required this.episode});

  final TVEpisode episode;

  @override
  State<EpisodeMetadata> createState() => _EpisodeMetadataState();
}

class _EpisodeMetadataState extends State<EpisodeMetadata> {
  late final _controller1 = TextEditingController(text: widget.episode.title);
  late final _controller2 = TextEditingController(text: widget.episode.episode.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.titleEditMetadata),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller1,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.title),
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: AppLocalizations.of(context)!.formLabelTitle,
                isDense: true,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              controller: _controller2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.numbers),
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: AppLocalizations.of(context)!.formLabelEpisode,
                isDense: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final number = int.tryParse(value);
                  if (number == null || number < 0 || number > 10000) {
                    return AppLocalizations.of(context)!.formValidatorEpisode;
                  } else {
                    return null;
                  }
                }
                return AppLocalizations.of(context)!.formValidatorEpisode;
              },
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            )
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop((_controller1.text, int.tryParse(_controller2.text)));
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
      ],
    );
  }
}
