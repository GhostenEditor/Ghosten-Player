import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'filled_button.dart';
import 'keyboard_reopen.dart';
import 'text_field_focus.dart';

class StepperForm extends StatefulWidget {
  const StepperForm({super.key, required this.items, required this.onComplete});

  final List<FormItem> items;
  final Function(Map<String, String?>) onComplete;

  @override
  State<StepperForm> createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
  late final _dirties = List.generate(widget.items.length, (_) => false);
  late final _focusNodes = List.generate(widget.items.length + 1, (_) => FocusNode());
  int _currentStep = 0;

  @override
  void dispose() {
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (_currentStep == 0) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _currentStep -= 1;
          });
        }
      },
      child: KeyboardReopen(
        child: Stepper(
          currentStep: _currentStep,
          steps: [
            ...widget.items.indexed.map(
              (entry) => Step(
                title: Text(entry.$2.labelText),
                isActive: _currentStep == entry.$1,
                state: _stepState(entry.$2, entry.$1),
                content: TextFieldFocus(
                  child: TextField(
                    controller: widget.items[entry.$1].controller,
                    focusNode: _focusNodes[entry.$1],
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: entry.$2.prefixIcon,
                      suffixIcon: entry.$2.suffixIcon,
                      helperText: entry.$2.helperText,
                      border: const OutlineInputBorder(),
                      errorText:
                          _dirties[entry.$1] && entry.$2.validator != null
                              ? entry.$2.validator!(widget.items[entry.$1].controller.text)
                              : null,
                    ),
                    obscureText: entry.$2.obscureText,
                    onEditingComplete: () {
                      setState(() {
                        _currentStep = entry.$1 + 1;
                        _dirties[entry.$1] = true;
                      });
                    },
                  ),
                ),
              ),
            ),
            Step(
              title: Text(AppLocalizations.of(context)!.buttonComplete),
              isActive: _currentStep == 2,
              content: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TVFilledButton(
                    focusNode: _focusNodes.last,
                    child: Text(AppLocalizations.of(context)!.buttonSubmit),
                    onPressed: () {
                      if (!widget.items.indexed.any(
                        (entry) =>
                            entry.$2.validator != null &&
                            entry.$2.validator!(widget.items[entry.$1].controller.text) != null,
                      )) {
                        widget.onComplete(
                          widget.items.indexed.fold({}, (acc, entry) {
                            acc[entry.$2.name] = widget.items[entry.$1].controller.text;
                            return acc;
                          }),
                        );
                      } else {
                        for (int i = 0; i < _dirties.length; i++) {
                          _dirties[i] = true;
                        }
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
          onStepTapped: (int index) {
            setState(() {
              _currentStep = index;
            });
          },
          controlsBuilder: (context, _) => const SizedBox(),
        ),
      ),
    );
  }

  StepState _stepState(FormItem item, int index) {
    if (_dirties[index]) {
      if (item.validator != null && item.validator!(widget.items[index].controller.text) != null) {
        return StepState.error;
      } else {
        if (index == _currentStep) {
          return StepState.editing;
        } else {
          return StepState.complete;
        }
      }
    } else {
      if (index == _currentStep) {
        return StepState.editing;
      } else {
        return StepState.indexed;
      }
    }
  }
}

class FormItem {
  FormItem(
    this.name, {
    required this.labelText,
    this.value,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(text: value);
  final String? value;
  final String labelText;
  final String? helperText;
  final String? hintText;
  final String name;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;
  final bool obscureText;
  final TextEditingController controller;
}
