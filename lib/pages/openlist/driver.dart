import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openlist/openlist.dart';

import '../../components/future_builder_handler.dart';
import '../../utils/utils.dart';
import 'storage_add.dart';

class OpenlistDrivers extends StatelessWidget {
  const OpenlistDrivers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('驱动列表')),
      body: Scrollbar(
        child: FutureBuilderHandler(
          future: Future.wait([
            OpenlistClient.driverNames(),
            rootBundle.loadString('assets/common/openlist_i18n/zh-CN/drivers.json').then(json.decode),
          ]),
          builder: (context, snapshot) {
            final drivers = snapshot.requireData[0] as List<String>;
            final i18n = snapshot.requireData[1];
            return ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final item = drivers[index];
                return ListTile(
                  title: Text(i18n['drivers'][item]),
                  onTap: () async {
                    final flag = await navigateTo<bool>(context, OpenlistStorageAdd(driver: item));
                    if ((flag ?? false) && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
