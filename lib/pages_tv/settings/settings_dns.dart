import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/gap.dart';
import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../components/filled_button.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/keyboard_reopen.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';

class SystemSettingsDNS extends StatefulWidget {
  const SystemSettingsDNS({super.key});

  @override
  State<SystemSettingsDNS> createState() => SystemSettingsDNSState();
}

class SystemSettingsDNSState extends State<SystemSettingsDNS> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemDNS,
      child: FutureBuilderHandler(
        future: Api.dnsOverrideQueryAll(),
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
            children: [
              ...snapshot.requireData.indexed.map(
                (entry) => SlidableSettingItem(
                  autofocus: entry.$1 == 0,
                  title: Text(entry.$2.domain, overflow: TextOverflow.ellipsis),
                  subtitle: Text(entry.$2.ip, overflow: TextOverflow.ellipsis),
                  actions: [
                    TVIconButton(
                      onPressed: () async {
                        final flag = await navigateToSlideLeft<bool>(context, _SystemSettingsDNSEdit(item: entry.$2));
                        if (flag ?? false) setState(() {});
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    TVIconButton(
                      onPressed: () async {
                        final confirm = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                        if ((confirm ?? false) && context.mounted) {
                          final resp = await showNotification(context, Api.dnsOverrideDeleteById(entry.$2.id));
                          if (resp?.error == null && context.mounted) setState(() {});
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
              const GapSettingItem(height: 12),
              IconButtonSettingItem(
                autofocus: snapshot.requireData.isEmpty,
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final flag = await navigateToSlideLeft<bool>(context, const _SystemSettingsDNSEdit());
                  if (flag ?? false) setState(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SystemSettingsDNSEdit extends StatefulWidget {
  const _SystemSettingsDNSEdit({DNSOverride? item}) : _item = item;
  final DNSOverride? _item;

  @override
  State<_SystemSettingsDNSEdit> createState() => _SystemSettingsDNSEditState();
}

class _SystemSettingsDNSEditState extends State<_SystemSettingsDNSEdit> {
  final _domains = ['api.themoviedb.org', 'image.tmdb.org'];
  late final _controller1 = TextEditingController(text: widget._item?.domain ?? _domains[0]);
  late final _controller2 = TextEditingController(text: widget._item?.ip);
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
      title: widget._item?.domain ?? AppLocalizations.of(context)!.pageTitleAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Form(
          key: _formKey,
          child: KeyboardReopen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DropdownButtonFormField(
                  value: _controller1.text,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dnsFormItemLabelDomain,
                    prefixIcon: const Icon(Icons.domain),
                    isDense: true,
                    hintText: '8.8.8.8',
                  ),
                  items: _domains.map((domain) => DropdownMenuItem(value: domain, child: Text(domain))).toList(),
                  validator: (value) => requiredValidator(context, value),
                  onChanged: (v) => setState(() => _controller1.text = v!),
                ),
                Gap.vMD,
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dnsFormItemLabelIP,
                    prefixIcon: const Icon(Icons.link),
                    isDense: true,
                    hintText: '8.8.8.8',
                  ),
                  controller: _controller2,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.formValidatorRequired;
                    } else {
                      final matches = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(value);
                      if (matches?.groupCount == 4) {
                        if (int.parse(matches![1]!) < 1 << 8 &&
                            int.parse(matches[2]!) < 1 << 8 &&
                            int.parse(matches[3]!) < 1 << 8 &&
                            int.parse(matches[4]!) < 1 << 8) {
                          return null;
                        }
                      }
                    }
                    return AppLocalizations.of(context)!.formValidatorIP;
                  },
                ),
                const Spacer(),
                TVFilledButton(
                  child: Text(AppLocalizations.of(context)!.buttonConfirm),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget._item == null) {
                        final resp = await showNotification(
                          context,
                          Api.dnsOverrideInsert(domain: _controller1.text.trim(), ip: _controller2.text.trim()),
                        );
                        if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                      } else {
                        final resp = await showNotification(
                          context,
                          Api.dnsOverrideUpdateById(
                            id: widget._item!.id,
                            domain: _controller1.text.trim(),
                            ip: _controller2.text.trim(),
                          ),
                        );
                        if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
