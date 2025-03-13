import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../validators/validators.dart';

class PromptFilename extends StatefulWidget {
  const PromptFilename({
    super.key,
    this.year,
    required this.text,
  });

  final String text;
  final int? year;

  @override
  State<PromptFilename> createState() => _PromptFilenameState();
}

class _PromptFilenameState extends State<PromptFilename> {
  late final _controller1 = TextEditingController(text: widget.text);
  late final _controller2 = TextEditingController(text: widget.year?.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.modalTitleNotification),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(AppLocalizations.of(context)!.searchNoResultTip, style: Theme.of(context).textTheme.labelSmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _controller1,
                autofocus: true,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.formLabelTitle,
                ),
                validator: (value) => requiredValidator(context, value),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                autofocus: true,
                controller: _controller2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.formLabelYear,
                ),
                validator: (value) => yearValidator(context, value),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
            )
          ],
        ),
      ),
      actions: [
        FilledButton(
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop((_controller1.text, int.tryParse(_controller2.text)));
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.buttonCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
