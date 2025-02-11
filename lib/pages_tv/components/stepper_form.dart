import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'filled_button.dart';

class StepperForm extends StatefulWidget {
  final List<FormItem> items;
  final Function(Map<String, String?>) onComplete;

  const StepperForm({super.key, required this.items, required this.onComplete});

  @override
  State<StepperForm> createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
  final formKey = GlobalKey<FormState>();

  late final dirties = List.generate(widget.items.length, (_) => false);
  late final focusNodes = List.generate(widget.items.length + 1, (_) => FocusNode());

  int currentStep = 0;

  @override
  void dispose() {
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
    for (final item in widget.items) {
      item.controller.dispose();
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
        if (currentStep == 0) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            currentStep -= 1;
          });
        }
      },
      child: Stepper(
        currentStep: currentStep,
        steps: [
          ...widget.items.indexed.map((entry) => Step(
              title: Text(entry.$2.labelText),
              isActive: currentStep == entry.$1,
              state: stepState(entry.$2, entry.$1),
              content: TextField(
                controller: widget.items[entry.$1].controller,
                focusNode: focusNodes[entry.$1],
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: entry.$2.prefixIcon,
                  suffixIcon: entry.$2.suffixIcon,
                  helperText: entry.$2.helperText,
                  border: const OutlineInputBorder(),
                  errorText: dirties[entry.$1] && entry.$2.validator != null ? entry.$2.validator!(widget.items[entry.$1].controller.text) : null,
                ),
                obscureText: entry.$2.obscureText,
                onEditingComplete: () {
                  setState(() {
                    currentStep = entry.$1 + 1;
                    dirties[entry.$1] = true;
                    Future.delayed(const Duration(milliseconds: 100)).then((_) => focusNodes[currentStep].requestFocus());
                  });
                },
              ))),
          Step(
            title: Text(AppLocalizations.of(context)!.buttonComplete),
            isActive: currentStep == 2,
            content: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TVFilledButton(
                  focusNode: focusNodes.last,
                  child: Text(AppLocalizations.of(context)!.buttonSubmit),
                  onPressed: () {
                    if (!widget.items.indexed
                        .any((entry) => entry.$2.validator != null ? entry.$2.validator!(widget.items[entry.$1].controller.text) != null : false)) {
                      widget.onComplete(widget.items.indexed.fold({}, (acc, entry) {
                        acc[entry.$2.name] = widget.items[entry.$1].controller.text;
                        return acc;
                      }));
                    } else {
                      for (int i = 0; i < dirties.length; i++) {
                        dirties[i] = true;
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
            currentStep = index;
          });
        },
        controlsBuilder: (context, _) => const SizedBox(),
      ),
    );
  }

  StepState stepState(FormItem item, int index) {
    if (dirties[index]) {
      if (item.validator != null && item.validator!(widget.items[index].controller.text) != null) {
        return StepState.error;
      } else {
        if (index == currentStep) {
          return StepState.editing;
        } else {
          return StepState.complete;
        }
      }
    } else {
      if (index == currentStep) {
        return StepState.editing;
      } else {
        return StepState.indexed;
      }
    }
  }
}

class FormItem {
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
}
