import 'package:flutter/material.dart' hide TextFormField;

import '../adaptive/adaptive.dart';
import '../utils/utils.dart';
import 'gap.dart';

abstract class FormItemBase<T> {
  const FormItemBase(this.name);

  final String name;

  T? get value;

  set value(T? v);

  void dispose();
}

class FormItem extends FormItemBase<String> {
  FormItem(
    super.name, {
    String? value,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    TextEditingController? controller,
    this.keyboardType,
  }) : controller = controller ?? TextEditingController(text: value);
  late final TextEditingController controller;

  final String? labelText;
  final String? helperText;
  final String? hintText;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  String? get value => controller.text.isEmpty ? null : controller.text;

  @override
  set value(String? v) {
    controller.text = v ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
  }
}

class DateFormItem extends FormItemBase<DateTime> {
  DateFormItem(
    super.name, {
    DateTime? value,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(text: value?.format());
  late final TextEditingController controller;

  final String? labelText;
  final String? helperText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;

  @override
  DateTime? get value => DateTime.tryParse(controller.text);

  @override
  set value(DateTime? v) {
    controller.text = v?.format() ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
  }
}

class IntFormItem extends FormItemBase<int> {
  IntFormItem(
    super.name, {
    int? value,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(text: value?.toString());
  late final TextEditingController controller;

  final String? labelText;
  final String? helperText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;

  @override
  int? get value => int.tryParse(controller.text);

  @override
  set value(int? v) {
    controller.text = v?.toString() ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
  }
}

class DoubleFormItem extends FormItemBase<double> {
  DoubleFormItem(
    super.name, {
    double? value,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(text: value?.toString());
  late final TextEditingController controller;

  final String? labelText;
  final String? helperText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;

  @override
  double? get value => double.tryParse(controller.text);

  @override
  set value(double? v) {
    controller.text = v?.toString() ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
  }
}

class DropdownFormItem<T> extends FormItemBase<T> {
  DropdownFormItem(
    super.name, {
    this.initialValue,
    this.labelText,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.items,
    this.onChanged,
  });

  final T? initialValue;
  final String? labelText;
  final String? helperText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  late final ValueNotifier<T?> _value = ValueNotifier(initialValue);

  @override
  T? get value => _value.value;

  @override
  set value(T? v) {
    _value.value = v;
  }

  @override
  void dispose() {
    _value.dispose();
  }
}

class FormGroupController {
  FormGroupController(this.items);

  final formKey = GlobalKey<FormState>();
  final List<FormItemBase<dynamic>> items;

  void dispose() {
    for (final FormItemBase<dynamic> item in items) {
      item.dispose();
    }
  }

  Map<String, dynamic> get data => Map.fromEntries(items.map((e) => MapEntry(e.name, e.value)));

  bool validate() {
    return formKey.currentState!.validate();
  }
}

class FormGroup extends StatefulWidget {
  const FormGroup({super.key, required this.controller, this.padding});

  final FormGroupController controller;
  final EdgeInsetsGeometry? padding;

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.formKey,
      child: ListView.separated(
        shrinkWrap: true,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemBuilder: (context, index) {
          final FormItemBase<dynamic> item = widget.controller.items[index];
          return switch (item) {
            final FormItem item => TextFormField(
              autofocus: index == 0,
              controller: item.controller,
              decoration: InputDecoration(
                labelText: item.labelText,
                helperText: item.helperText,
                hintText: item.hintText,
                prefixIcon: item.prefixIcon,
                suffixIcon: item.suffixIcon,
              ),
              minLines: 1,
              maxLines: item.maxLines,
              obscureText: item.obscureText,
              validator: item.validator,
              keyboardType: item.keyboardType,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            final DateFormItem item => TextFormField(
              autofocus: index == 0,
              controller: item.controller,
              decoration: InputDecoration(
                labelText: item.labelText,
                helperText: item.helperText,
                hintText: item.hintText,
                prefixIcon: item.prefixIcon,
                suffixIcon: item.suffixIcon,
              ),
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: item.value,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  item.value = date;
                }
              },
              keyboardType: .datetime,
              validator: item.validator,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            final IntFormItem item => TextFormField(
              autofocus: index == 0,
              controller: item.controller,
              decoration: InputDecoration(
                labelText: item.labelText,
                helperText: item.helperText,
                hintText: item.hintText,
                prefixIcon: item.prefixIcon,
                suffixIcon: item.suffixIcon,
              ),
              keyboardType: .number,
              validator: item.validator,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            final DoubleFormItem item => TextFormField(
              autofocus: index == 0,
              controller: item.controller,
              decoration: InputDecoration(
                labelText: item.labelText,
                helperText: item.helperText,
                hintText: item.hintText,
                prefixIcon: item.prefixIcon,
                suffixIcon: item.suffixIcon,
              ),
              keyboardType: .number,
              validator: item.validator,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            final DropdownFormItem<dynamic> item => ValueListenableBuilder(
              valueListenable: item._value,
              builder: (context, value, _) {
                return DropdownButtonFormField<dynamic>(
                  initialValue: value,
                  decoration: InputDecoration(
                    prefixIcon: item.prefixIcon,
                    border: const UnderlineInputBorder(),
                    isDense: true,
                    labelText: item.labelText,
                  ),
                  items: item.items,
                  onChanged: (code) {
                    if (code == null) {
                      return;
                    }
                    item.value = code;
                  },
                );
              },
            ),
            _ => throw UnimplementedError(),
          };
        },
        itemCount: widget.controller.items.length,
        separatorBuilder: (context, index) => Gap.vSM,
      ),
    );
  }
}
