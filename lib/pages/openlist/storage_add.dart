import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openlist/openlist.dart';

import '../../components/future_builder_handler.dart';
import '../../validators/validators.dart';
import '../utils/notification.dart';

class OpenlistStorageAdd extends StatefulWidget {
  const OpenlistStorageAdd({super.key, this.initialData, required this.driver});

  final String driver;
  final StorageInfo? initialData;

  @override
  State<OpenlistStorageAdd> createState() => _OpenlistStorageAddState();
}

class _OpenlistStorageAddState extends State<OpenlistStorageAdd> {
  final _formKey = GlobalKey<FormState>();

  final _commonControllers = <String, TextEditingController>{};
  final _commonValues = <String, dynamic>{};
  final _additionalControllers = <String, TextEditingController>{};
  final _additionalValues = <String, dynamic>{};
  final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: FutureBuilderHandler(
            future: Future.wait([_driverInfoFuture(), _i18nFuture()]),
            builder: (context, snapshot) {
              final driverInfo = snapshot.requireData[0] as DriverInfo;
              final i18n = snapshot.requireData[1];
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    title: Text(widget.initialData == null ? '添加' : '编辑'),
                    pinned: true,
                    actions: [
                      IconButton(onPressed: () => _onSubmit(driverInfo), icon: const Icon(Icons.check_rounded)),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        initialValue: i18n['drivers'][widget.driver],
                        decoration: InputDecoration(labelText: '驱动'),
                        enabled: false,
                      ),
                    ),
                  ),
                  OpenlistLocalizations(
                    i18n['common'],
                    child: _AddForm(items: driverInfo.common, controllers: _commonControllers, values: _commonValues),
                  ),
                  OpenlistLocalizations(
                    i18n[widget.driver],
                    child: _AddForm(
                      items: driverInfo.additional,
                      controllers: _additionalControllers,
                      values: _additionalValues,
                    ),
                  ),
                  const SliverSafeArea(sliver: SliverToBoxAdapter()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSubmit(DriverInfo driverInfo) async {
    if (_formKey.currentState!.validate()) {
      final a = {
        'id': widget.initialData?.id,
        'driver': widget.driver,
        ..._commonValues,
        ..._commonControllers.entries.fold(
          {},
          (acc, cur) =>
              acc..putIfAbsent(cur.key, () => _resolveControllerValue(cur.key, cur.value.text, driverInfo.common)),
        ),
        'addition': jsonEncode({
          ..._additionalValues,
          ..._additionalControllers.entries.fold(
            {},
            (acc, cur) =>
                acc
                  ..putIfAbsent(cur.key, () => _resolveControllerValue(cur.key, cur.value.text, driverInfo.additional)),
          ),
        }),
      };
      final resp = await showNotification(
        context,
        widget.initialData == null ? OpenlistClient.storageCreate(a) : OpenlistClient.storageUpdate(a),
      );
      if (resp?.error == null && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  dynamic _resolveControllerValue(String key, String? value, List<DriverInfoItem> items) {
    return switch (items.firstWhere((item) => item.name == key).type) {
      DriverInfoItemType.string => value,
      DriverInfoItemType.text => value,
      DriverInfoItemType.number => int.tryParse(value!),
      DriverInfoItemType.float => double.tryParse(value!),
      DriverInfoItemType.select => throw UnimplementedError(),
      DriverInfoItemType.bool => throw UnimplementedError(),
    };
  }

  Future<dynamic> _i18nFuture() {
    return Future.wait([
      rootBundle.loadString('assets/common/openlist_i18n/zh-CN/storages.json').then(json.decode),
      rootBundle.loadString('assets/common/openlist_i18n/zh-CN/drivers.json').then(json.decode),
    ]).then((data) => data[1]..['common'] = data[0]['common']);
  }

  Future<DriverInfo> _driverInfoFuture() async {
    final a = await OpenlistClient.driverInfo(widget.driver);
    if (widget.initialData != null) {
      for (var index = 0; index < a.common.length; index++) {
        final item = a.common[index];
        var value = widget.initialData?.get(item.name);
        if (item.type == DriverInfoItemType.number ||
            item.type == DriverInfoItemType.float ||
            item.type == DriverInfoItemType.bool) {
          value = value.toString();
        }
        if (value != null) {
          a.common[index] = item.copyWith(default_: value);
        }
      }

      for (var index = 0; index < a.additional.length; index++) {
        final item = a.additional[index];
        var value = widget.initialData?.getAddition(item.name);
        if (item.type == DriverInfoItemType.number ||
            item.type == DriverInfoItemType.float ||
            item.type == DriverInfoItemType.bool) {
          value = value.toString();
        }
        if (value != null) {
          a.additional[index] = item.copyWith(default_: value);
        }
      }
    }

    return a;
  }
}

class _AddForm extends StatefulWidget {
  const _AddForm({super.key, required this.items, required this.controllers, required this.values});

  final List<DriverInfoItem> items;
  final Map<String, TextEditingController> controllers;

  final Map<String, dynamic> values;

  @override
  State<_AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<_AddForm> {
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AddForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.list(children: widget.items.map((item) => _buildFormItem(context, item)).toList());
  }

  Widget _buildFormItem(BuildContext context, DriverInfoItem item) {
    final i18n = OpenlistLocalizations.of(context);
    return switch (item.type) {
      DriverInfoItemType.string => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: widget.controllers[item.name],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            label: _buildLabel(context, item, i18n),
            helperText: i18n.i18n('${item.name}-tips') ?? item.help,
          ),
          validator: item.required ? (value) => requiredValidator(context, value) : null,
        ),
      ),
      DriverInfoItemType.number => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: widget.controllers[item.name],
          keyboardType: TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9]'))],
          contextMenuBuilder: null,
          decoration: InputDecoration(
            label: _buildLabel(context, item, i18n),
            helperText: i18n.i18n('${item.name}-tips') ?? item.help,
          ),
          validator: item.required ? (value) => requiredValidator(context, value) : null,
        ),
      ),
      DriverInfoItemType.float => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: widget.controllers[item.name],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-.0-9]'))],
          contextMenuBuilder: null,
          decoration: InputDecoration(
            label: _buildLabel(context, item, i18n),
            helperText: i18n.i18n('${item.name}-tips') ?? item.help,
          ),
          validator: item.required ? (value) => requiredValidator(context, value) : null,
        ),
      ),
      DriverInfoItemType.text => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: widget.controllers[item.name],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            label: _buildLabel(context, item, i18n),
            helperText: i18n.i18n('${item.name}-tips') ?? item.help,
          ),
          maxLines: 5,
          minLines: 1,
          validator: item.required ? (value) => requiredValidator(context, value) : null,
        ),
      ),
      DriverInfoItemType.select => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField(
          value: widget.values[item.name] as String?,
          decoration: InputDecoration(
            label: _buildLabel(context, item, i18n),
            helperText: i18n.i18n('${item.name}-tips') ?? item.help,
          ),
          items:
              item.options
                  .map(
                    (domain) =>
                        DropdownMenuItem(value: domain, child: Text(i18n.i18n('${item.name}s')?[domain] ?? domain)),
                  )
                  .toList(),
          validator: item.required ? (String? value) => requiredValidator(context, value) : null,
          onChanged: (value) async {
            widget.values.update(item.name, (_) => value);
          },
        ),
      ),
      DriverInfoItemType.bool => SwitchListTile(
        title: Text(i18n.i18n(item.name) ?? item.name),
        subtitle:
            i18n.i18n('${item.name}-tips') != null
                ? Text(i18n.i18n('${item.name}-tips'))
                : item.help != null
                ? Text(item.help!)
                : null,
        value: widget.values[item.name],
        onChanged: (value) {
          setState(() {
            widget.values.update(item.name, (_) => value);
          });
        },
      ),
    };
  }

  Widget _buildLabel(BuildContext context, DriverInfoItem item, OpenlistLocalizations i18n) {
    if (item.required) {
      return Row(
        children: [Text(i18n.i18n(item.name) ?? item.name), const Text(' *', style: TextStyle(color: Colors.red))],
      );
    } else {
      return Text(i18n.i18n(item.name) ?? item.name);
    }
  }

  void _initControllers() {
    for (final entry in widget.controllers.entries) {
      entry.value.dispose();
    }
    widget.controllers.clear();
    widget.values.clear();
    for (final item in widget.items) {
      switch (item.type) {
        case DriverInfoItemType.string:
        case DriverInfoItemType.number:
        case DriverInfoItemType.float:
        case DriverInfoItemType.text:
          widget.controllers.putIfAbsent(item.name, () => TextEditingController(text: item.default_));
        case DriverInfoItemType.select:
          if (item.options.contains(item.default_)) {
            widget.values.putIfAbsent(item.name, () => item.default_);
          } else {
            widget.values.putIfAbsent(item.name, () => null);
          }

        case DriverInfoItemType.bool:
          widget.values.putIfAbsent(item.name, () => item.default_ == 'true');
      }
    }
  }
}

class OpenlistLocalizations extends InheritedWidget {
  const OpenlistLocalizations(this.data, {super.key, required super.child});

  final dynamic data;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static OpenlistLocalizations of(BuildContext context) {
    return context.getInheritedWidgetOfExactType()!;
  }

  dynamic i18n(String key) {
    return data[key];
  }
}
