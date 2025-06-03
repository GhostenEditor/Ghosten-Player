import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/stream_builder_handler.dart';
import '../../l10n/app_localizations.dart';

class SettingsDiagnotics extends StatelessWidget {
  const SettingsDiagnotics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemNetworkDiagnotics)),
      body: StreamBuilderHandler(
        stream: Api.networkDiagnostics(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemBuilder: (context, index) {
              if (index < snapshot.requireData.length) {
                final item = snapshot.requireData[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
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
                );
              } else {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.requireData.every((item) => item.status == NetworkDiagnoticsStatus.success)) {
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.networkStatus(NetworkDiagnoticsStatus.success.name)),
                    );
                  } else {
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.networkStatus(NetworkDiagnoticsStatus.fail.name)),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            },
            itemCount: snapshot.requireData.length + 1,
          );
        },
      ),
    );
  }
}
