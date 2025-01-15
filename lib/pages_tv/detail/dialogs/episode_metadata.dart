import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/gap.dart';
import '../../components/filled_button.dart';
import '../../components/setting.dart';
import '../../components/text_button.dart';

class EpisodeMetadata extends StatefulWidget {
  final TVEpisode episode;

  const EpisodeMetadata({super.key, required this.episode});

  @override
  State<EpisodeMetadata> createState() => _EpisodeMetadataState();
}

class _EpisodeMetadataState extends State<EpisodeMetadata> {
  late final _controller1 = TextEditingController(text: widget.episode.title);
  late final _controller2 = TextEditingController(text: widget.episode.episode.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.titleEditMetadata,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                autofocus: true,
                controller: _controller1,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title),
                  labelText: AppLocalizations.of(context)!.formLabelTitle,
                  isDense: true,
                ),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
              Gap.vMD,
              TextFormField(
                autofocus: true,
                controller: _controller2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.numbers),
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
              const Spacer(),
              TVFilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop((_controller1.text, int.tryParse(_controller2.text)));
                  }
                },
                child: Text(AppLocalizations.of(context)!.buttonConfirm),
              ),
              Gap.vSM,
              TVTextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.buttonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
