import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/function.dart';
import 'gap.dart';

class ServerSwitcher extends StatelessWidget {
  const ServerSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    return function.multiServers && function.server != null
        ? Row(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              if (function.server!.username != null)
                Text(function.server!.username!, style: const TextStyle(fontWeight: .w500)),
              IconButton(
                onPressed: () => showModal(context: context, builder: (context) => const _ServerSwitcherDialog()),
                icon: const Icon(Icons.public_rounded),
                // icon: const Material(shape: CircleBorder(), clipBehavior: .antiAlias, child: Logo(size: 40)),
                padding: .zero,
              ),
            ],
          )
        : const SizedBox();
  }
}

class _ServerSwitcherDialog extends StatelessWidget {
  const _ServerSwitcherDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsItemServer),
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 400),
      content: FutureBuilder(
        future: Api.serverQueryAll(),
        builder: (context, snapshot) => snapshot.hasData
            ? ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) {
                  final Server item = snapshot.requireData[index];
                  return ListTile(
                    autofocus: item.active,
                    leading: IgnorePointer(
                      child: RadioGroup(groupValue: item.active, onChanged: (_) {}, child: const Radio(value: true)),
                    ),
                    selected: item.active,
                    onTap: () async {
                      await Api.serverActiveById(item.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    title: Text(AppLocalizations.of(context)!.driverType(item.type.name)),
                    subtitle: item.username != null ? Text(item.username!) : null,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Gap.vSM,
              )
            : const SizedBox(),
      ),
    );
  }
}
