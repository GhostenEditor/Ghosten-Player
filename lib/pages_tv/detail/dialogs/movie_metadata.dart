import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/gap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';
import '../../components/filled_button.dart';
import '../../components/keyboard_reopen.dart';
import '../../components/setting.dart';
import '../../components/text_field_focus.dart';

class MovieMetadata extends StatefulWidget {
  const MovieMetadata({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieMetadata> createState() => _MovieMetadataState();
}

class _MovieMetadataState extends State<MovieMetadata> {
  late final _controller1 = TextEditingController(text: widget.movie.title);
  late final _controller2 = TextEditingController(text: widget.movie.originalTitle);
  late final _controller3 = TextEditingController(text: widget.movie.releaseDate?.format());
  late final _controller4 = TextEditingController(text: widget.movie.overview);
  late final _controller5 = TextEditingController(text: widget.movie.voteAverage.toString());
  late final _controller6 = TextEditingController(text: widget.movie.voteCount.toString());
  late final _controller7 = TextEditingController(text: widget.movie.duration?.inSeconds.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    _controller7.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.titleEditMetadata,
      child: Form(
        key: _formKey,
        child: KeyboardReopen(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            children: [
              TextFieldFocus(
                child: TextFormField(
                  autofocus: true,
                  controller: _controller1,
                  decoration: InputDecoration(isDense: true, labelText: AppLocalizations.of(context)!.formLabelTitle),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  controller: _controller2,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.formLabelOriginalTitle,
                  ),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  controller: _controller3,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
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
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  controller: _controller4,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.formLabelPlot,
                  ),
                  maxLines: 6,
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  controller: _controller5,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.formLabelVoteAverage,
                  ),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller6,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.formLabelVoteCount,
                  ),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller7,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.formLabelRuntime,
                    suffix: Text(AppLocalizations.of(context)!.second),
                  ),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vSM,
              Align(
                alignment: Alignment.centerRight,
                child: TVFilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await Api.movieMetadataUpdateById({
                        'id': widget.movie.id,
                        'title': _controller1.text,
                        'originalTitle': _controller2.text,
                        'releaseDate': _controller3.text,
                        'overview': _controller4.text,
                        'voteAverage': double.parse(_controller5.text),
                        'voteCount': int.parse(_controller6.text),
                        'duration': int.parse(_controller7.text),
                      });
                      if (context.mounted) Navigator.pop(context, true);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.buttonConfirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
