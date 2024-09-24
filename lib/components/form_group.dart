import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FormItem {
  late final TextEditingController controller;

  final focusNode = FocusNode();
  final String? labelText;
  final String? helperText;
  final String? hintText;
  final String name;
  final IconData? prefixIcon;
  final FormFieldValidator<String?>? validator;
  final bool obscureText;

  FormItem(
    this.name, {
    String? value,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
  }) {
    controller = TextEditingController(text: value);
  }

  String? get value => controller.text.isEmpty ? null : controller.text;

  bool get focused => focusNode.hasFocus;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class FormGroupController {
  final formKey = GlobalKey<FormState>();
  final List<FormItem> items;

  FormGroupController(this.items);

  void dispose() {
    for (final item in items) {
      item.dispose();
    }
  }

  Map<String, dynamic> get data => Map.fromEntries(items.map((e) => MapEntry(e.name, e.value)));

  bool validate() {
    return formKey.currentState!.validate();
  }

  FormItem? get focusedItem => items.firstWhereOrNull((item) => item.focused);
}

class FormGroup extends StatefulWidget {
  final FormGroupController controller;

  const FormGroup({super.key, required this.controller});

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.formKey,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemBuilder: (context, index) {
          final item = widget.controller.items[index];
          return TextFormField(
            controller: item.controller,
            focusNode: item.focusNode,
            decoration: InputDecoration(
              isDense: true,
              labelText: item.labelText,
              helperText: item.helperText,
              hintText: item.hintText,
              prefixIcon: Icon(item.prefixIcon),
            ),
            obscureText: item.obscureText,
            validator: item.validator,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
          );
        },
        itemCount: widget.controller.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 18),
      ),
    );
  }
}
