import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/gap.dart';
import '../../../l10n/app_localizations.dart';
import '../../components/filled_button.dart';
import '../../components/keyboard_reopen.dart';
import '../../components/setting.dart';
import '../../components/text_button.dart';

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
    return SettingPage(
      title: AppLocalizations.of(context)!.titleEditMetadata,
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers),
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
                const Spacer(),
                TVFilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, int.tryParse(_controller.text));
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
      ),
    );
  }
}
