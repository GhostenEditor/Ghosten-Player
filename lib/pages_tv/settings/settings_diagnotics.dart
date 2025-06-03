import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../components/loading.dart';
import '../components/setting.dart';
import '../components/stream_builder_handler.dart';

class SettingsDiagnotics extends StatelessWidget {
  const SettingsDiagnotics({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemNetworkDiagnotics,
      child: StreamBuilderHandler(
        stream: Api.networkDiagnostics(),
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
            children: [
              ...snapshot.requireData.map(
                (item) => ButtonSettingItem(
                  title: Text(item.domain),
                  subtitle:
                      item.ip != null
                          ? Text(item.ip!)
                          : item.error != null
                          ? Text('${item.error!}\n${item.tip ?? ''}')
                          : null,
                  trailing: switch (item.status) {
                    NetworkDiagnoticsStatus.success => Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.green),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                    NetworkDiagnoticsStatus.fail => Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red),
                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                    ),
                  },
                  onTap: () {},
                ),
              ),
              if (snapshot.connectionState == ConnectionState.done)
                snapshot.requireData.every((item) => item.status == NetworkDiagnoticsStatus.success)
                    ? ButtonSettingItem(
                      title: Text(AppLocalizations.of(context)!.networkStatus(NetworkDiagnoticsStatus.success.name)),
                    )
                    : ButtonSettingItem(
                      title: Text(AppLocalizations.of(context)!.networkStatus(NetworkDiagnoticsStatus.fail.name)),
                    )
              else
                const Loading(),
            ],
          );
        },
      ),
    );
  }
}
