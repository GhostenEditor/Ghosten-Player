import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../utils/notification.dart';

class SystemSettingsDNS extends StatefulWidget {
  const SystemSettingsDNS({super.key});

  @override
  State<SystemSettingsDNS> createState() => SystemSettingsDNSState();
}

class SystemSettingsDNSState extends State<SystemSettingsDNS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsItemDNS),
        actions: [
          IconButton(
            onPressed: () async {
              final flag = await navigateTo<bool>(context, const _SystemSettingsDNSEdit());
              if (flag ?? false) setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilderHandler<List<DNSOverride>>(
        future: Api.dnsOverrideQueryAll(),
        builder: (context, snapshot) {
          return snapshot.requireData.isEmpty
              ? const NoData()
              : ListView.builder(
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  return ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            AppLocalizations.of(context)!.dnsFormItemLabelDomain,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(child: Text(item.domain, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            AppLocalizations.of(context)!.dnsFormItemLabelIP,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(child: Text(item.ip, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final flag = await navigateTo<bool>(context, _SystemSettingsDNSEdit(item: item));
                      if (flag ?? false) setState(() {});
                    },
                  );
                },
              );
        },
      ),
    );
  }
}

class _SystemSettingsDNSEdit extends StatefulWidget {
  const _SystemSettingsDNSEdit({this.item});

  final DNSOverride? item;

  @override
  State<_SystemSettingsDNSEdit> createState() => _SystemSettingsDNSEditState();
}

class _SystemSettingsDNSEditState extends State<_SystemSettingsDNSEdit> {
  final _domains = ['api.themoviedb.org', 'image.tmdb.org'];
  late final _controller1 = TextEditingController(text: widget.item?.domain ?? _domains[0]);
  late final _controller2 = TextEditingController(text: widget.item?.ip);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item?.domain ?? AppLocalizations.of(context)!.pageTitleAdd),
        actions: [
          if (widget.item != null)
            IconButton(
              onPressed: () async {
                final confirm = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                if (confirm != true) return;
                if (context.mounted) await showNotification(context, Api.dnsOverrideDeleteById(widget.item!.id));
                if (context.mounted) Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (widget.item == null) {
                  final resp = await showNotification(
                    context,
                    Api.dnsOverrideInsert(domain: _controller1.text.trim(), ip: _controller2.text.trim()),
                  );
                  if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                } else {
                  final resp = await showNotification(
                    context,
                    Api.dnsOverrideUpdateById(
                      id: widget.item!.id,
                      domain: _controller1.text.trim(),
                      ip: _controller2.text.trim(),
                    ),
                  );
                  if (resp?.error == null && context.mounted) Navigator.of(context).pop(true);
                }
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 12,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
