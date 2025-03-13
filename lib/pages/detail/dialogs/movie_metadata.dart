import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../validators/validators.dart';

class MovieMetadata extends StatefulWidget {
  const MovieMetadata({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieMetadata> createState() => _MovieMetadataState();
}

class _MovieMetadataState extends State<MovieMetadata> {
  late final _controller1 = TextEditingController(text: widget.movie.title);
  late final _controller2 = TextEditingController(text: widget.movie.airDate?.year.toString());
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
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelTitle,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              controller: _controller2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelYear,
              ),
              validator: (value) => yearValidator(context, value),
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
