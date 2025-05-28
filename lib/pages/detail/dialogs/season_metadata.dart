import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class SeasonMetadata extends StatefulWidget {
  const SeasonMetadata({super.key, required this.season});

  final TVSeason season;

  @override
  State<SeasonMetadata> createState() => _SeasonMetadataState();
}

class _SeasonMetadataState extends State<SeasonMetadata> {
  late final _controller = TextEditingController(text: widget.season.season.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.titleEditMetadata),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.numbers),
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelSeason,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final season = int.tryParse(value);
                  if (season == null || season < 0 || season > 100) {
                    return AppLocalizations.of(context)!.formValidatorSeason;
                  }
                }
                return null;
              },
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, int.tryParse(_controller.text));
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.buttonCancel)),
      ],
    );
  }
}
