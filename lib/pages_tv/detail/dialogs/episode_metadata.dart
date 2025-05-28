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

class EpisodeMetadata extends StatefulWidget {
  const EpisodeMetadata({super.key, required this.episode});

  final TVEpisode episode;

  @override
  State<EpisodeMetadata> createState() => _EpisodeMetadataState();
}

class _EpisodeMetadataState extends State<EpisodeMetadata> {
  late final _controller1 = TextEditingController(text: widget.episode.title);
  late final _controller2 = TextEditingController(text: widget.episode.episode.toString());
  late final _controller3 = TextEditingController(text: widget.episode.airDate?.format());
  late final _controller4 = TextEditingController(text: widget.episode.overview);
  late final _controller5 = TextEditingController(text: widget.episode.duration?.inSeconds.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
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
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.formLabelTitle, isDense: true),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  autofocus: true,
                  controller: _controller2,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
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
                ),
              ),
              Gap.vMD,
              TextFieldFocus(
                child: TextFormField(
                  autofocus: true,
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
                  autofocus: true,
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
                  autofocus: true,
                  controller: _controller5,
                  keyboardType: TextInputType.number,
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
              Gap.vMD,
              Align(
                alignment: Alignment.bottomRight,
                child: TVFilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await Api.tvEpisodeMetadataUpdateById({
                        'id': widget.episode.id,
                        'title': _controller1.text,
                        'episode': int.parse(_controller2.text),
                        'airDate': _controller3.text,
                        'overview': _controller4.text,
                        'duration': int.parse(_controller5.text),
                      });
                      if (context.mounted) Navigator.of(context).pop(true);
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
