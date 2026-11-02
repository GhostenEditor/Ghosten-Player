import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile, TextFormField;
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../adaptive/adaptive.dart';
import '../menus/dns.dart';
import '../view_models/view_models.dart';

class SystemSettingsDNS extends StatefulWidget {
  const SystemSettingsDNS({super.key});

  @override
  State<SystemSettingsDNS> createState() => SystemSettingsDNSState();
}

class SystemSettingsDNSState extends State<SystemSettingsDNS> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemDNS),
      actions: [IconButton(onPressed: () => context.pushNamed(.settingsDnsEdit), icon: const Icon(Icons.add))],
      child: ListViewModelConsumer<DNDListViewModel, DNSOverride>(
        builder: (context, items, _) => ListView.builder(
          padding: SettingPageTheme.of(context).contentPadding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final DNSOverride item = items[index];
            return ActionListTile(
              leading: const Icon(Icons.dns_outlined),
              title: Text(item.domain, overflow: TextOverflow.ellipsis),
              subtitle: Text(item.ip, overflow: TextOverflow.ellipsis),
              actions: DNSMenu(item),
            );
          },
        ),
      ),
    );
  }
}

class DNDListViewModel extends ListViewModelBase<DNSOverride> {
  DNDListViewModel() {
    _subscription = EventDispatcher.where(type: .dns).listen((_) => load());
  }

  StreamSubscription<EventData>? _subscription;

  @override
  AsyncSnapshot<List<DNSOverride>> snapshot = const AsyncSnapshot.waiting();

  @override
  Future<void> load() async {
    try {
      final List<DNSOverride> data = await Api.dnsOverrideQueryAll();
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const SystemSettingsDNS());
  }
}

const _domains = ['api.themoviedb.org', 'image.tmdb.org'];

class SystemSettingsDNSEdit extends StatefulWidget {
  const SystemSettingsDNSEdit({super.key, this.item});

  final DNSOverride? item;

  @override
  State<SystemSettingsDNSEdit> createState() => _SystemSettingsDNSEditState();
}

class _SystemSettingsDNSEditState extends State<SystemSettingsDNSEdit> {
  late final _controller = FormGroupController([
    DropdownFormItem(
      'domain',
      items: _domains.map((domain) => DropdownMenuItem(value: domain, child: Text(domain))).toList(),
      validator: (value) => requiredValidator(context, value),
      initialValue: widget.item?.domain ?? _domains[0],
      labelText: AppLocalizations.of(context)!.dnsFormItemLabelDomain,
      prefixIcon: const Icon(Icons.domain),
      hintText: '8.8.8.8',
    ),
    FormItem(
      'ip',
      value: widget.item?.ip,
      labelText: AppLocalizations.of(context)!.dnsFormItemLabelIP,
      prefixIcon: const Icon(Icons.link),
      hintText: '8.8.8.8',
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.formValidatorRequired;
        } else {
          final RegExpMatch? matches = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(value);
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
  ]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: Text(widget.item?.domain ?? AppLocalizations.of(context)!.pageTitleAdd),
      onConfirmButtonPressed: () async {
        if (_controller.validate()) {
          final String domain = (_controller.data['domain'] as String).trim();
          final String ip = (_controller.data['ip'] as String).trim();
          final Future<void> future = widget.item == null
              ? Api.dnsOverrideInsert(domain: domain, ip: ip)
              : Api.dnsOverrideUpdateById(id: widget.item!.id, domain: domain, ip: ip);
          final AsyncSnapshot<void>? resp = await showNotification(context, future);
          if (resp?.error == null && context.mounted) {
            Navigator.of(context).pop(true);
          }
        }
      },
      child: FormGroup(controller: _controller),
    );
  }
}
