import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../validators/validators.dart';
import '../../components/filled_button.dart';
import '../../components/keyboard_reopen.dart';
import '../../components/text_button.dart';

class SearchNoResult extends StatefulWidget {
  const SearchNoResult({super.key, required this.text, this.year});

  final String text;
  final int? year;

  @override
  State<SearchNoResult> createState() => _SearchNoResultState();
}

class _SearchNoResultState extends State<SearchNoResult> {
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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/tv/images/bg-stripe.png'), repeat: ImageRepeat.repeat),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0x61),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.2, 0.5],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.searchNoResultTip,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 64),
                  Flexible(
                    flex: 3,
                    child: KeyboardReopen(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _controller1,
                              autofocus: true,
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
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
                                isDense: true,
                                labelText: AppLocalizations.of(context)!.formLabelYear,
                              ),
                              validator: (value) => yearValidator(context, value),
                              onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TVFilledButton(
                              child: Text(AppLocalizations.of(context)!.buttonConfirm),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.of(context).pop((_controller1.text, int.tryParse(_controller2.text)));
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TVTextButton(
                              child: Text(AppLocalizations.of(context)!.buttonCancel),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
