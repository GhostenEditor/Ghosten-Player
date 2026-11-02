import 'package:flutter/material.dart' hide ListTile, RadioListTile;

import '../../../components/components.dart';
import '../../../utils/utils.dart';
import 'list_tile.dart';
import 'radio_list_tile.dart';
import 'setting_page.dart';

class MenuListTile<T> extends StatelessWidget {
  const MenuListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    required this.onSelected,
    required this.itemBuilder,
    this.initialValue,
  });

  final T? initialValue;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final PopupMenuItemSelected<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      trailing: trailing,
      title: title,
      subtitle: subtitle,
      onTap: () => navigateToSlideLeft(
        context,
        _SubmenuSelectPage<T>(title: title, itemBuilder: itemBuilder, onSelected: onSelected, groupValue: initialValue),
      ),
    );
  }
}

class _SubmenuSelectPage<T> extends StatefulWidget {
  const _SubmenuSelectPage({
    super.key,
    this.title,
    required this.itemBuilder,
    required this.onSelected,
    this.groupValue,
  });

  final T? groupValue;
  final Widget? title;
  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T> onSelected;

  @override
  State<_SubmenuSelectPage<T>> createState() => _SubmenuSelectPageState<T>();
}

class _SubmenuSelectPageState<T> extends State<_SubmenuSelectPage<T>> {
  late T? groupValue = widget.groupValue;

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: widget.title,
      child: ListView(
        padding: SettingPageTheme.of(context).contentPadding,
        children: widget.itemBuilder(context).map((item) {
          if (item is CheckedPopupMenuItem<T>) {
            return RadioListTile(
              value: item.value,
              autofocus: item.checked,
              dense: true,
              groupValue: groupValue,
              onChanged: (value) {
                groupValue = value;
                widget.onSelected(groupValue as T);
                setState(() {});
              },
              title: item.child,
            );
          } else if (item is PopupMenuItem<T>) {
            return ListTile(title: item.child, dense: true);
          } else if (item is Divider) {
            return const Divider();
          } else {
            return item;
          }
        }).toList(),
      ),
    );
  }
}
