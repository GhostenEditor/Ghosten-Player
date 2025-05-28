import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';
import '../../utils/notification.dart';

class SeriesMetadata extends StatefulWidget {
  const SeriesMetadata({super.key, required this.series});

  final TVSeries series;

  @override
  State<SeriesMetadata> createState() => _SeriesMetadataState();
}

class _SeriesMetadataState extends State<SeriesMetadata> {
  late final _controller1 = TextEditingController(text: widget.series.title);
  late final _controller2 = TextEditingController(text: widget.series.originalTitle);
  late final _controller3 = TextEditingController(text: widget.series.firstAirDate?.format());
  late final _controller4 = TextEditingController(text: widget.series.overview);
  late final _controller5 = TextEditingController(text: widget.series.voteAverage.toString());
  late final _controller6 = TextEditingController(text: widget.series.voteCount.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
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
          spacing: 4,
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller1,
              decoration: InputDecoration(
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
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelOriginalTitle,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              controller: _controller3,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelAirDate,
              ),
              keyboardType: TextInputType.datetime,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_controller3.text),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _controller3.text = date.format();
                }
              },
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              controller: _controller4,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelPlot,
              ),
              maxLines: 6,
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              controller: _controller5,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelVoteAverage,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: _controller6,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelVoteCount,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final resp = await showNotification(
                context,
                showSuccess: false,
                Api.tvSeriesMetadataUpdateById({
                  'id': widget.series.id,
                  'title': _controller1.text,
                  'originalTitle': _controller2.text,
                  'firstAirDate': _controller3.text,
                  'overview': _controller4.text,
                  'voteAverage': double.parse(_controller5.text),
                  'voteCount': int.parse(_controller6.text),
                }),
              );
              if (resp?.error == null) {
                if (context.mounted) Navigator.pop(context, true);
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.buttonCancel)),
      ],
    );
  }
}
