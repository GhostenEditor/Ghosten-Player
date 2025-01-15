import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/gap.dart';
import '../../../validators/validators.dart';
import '../../components/filled_button.dart';
import '../../components/setting.dart';
import '../../components/text_button.dart';

class MovieMetadata extends StatefulWidget {
  final Movie movie;

  const MovieMetadata({super.key, required this.movie});

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
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.formLabelTitle,
                ),
                validator: (value) => requiredValidator(context, value),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
              Gap.vMD,
              TextFormField(
                autofocus: true,
                controller: _controller2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                  isDense: true,
                  labelText: AppLocalizations.of(context)!.formLabelYear,
                ),
                validator: (value) => yearValidator(context, value),
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
