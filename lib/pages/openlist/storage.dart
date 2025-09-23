import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openlist/openlist.dart';

import '../../components/future_builder_handler.dart';
import '../../utils/utils.dart';
import '../utils/notification.dart';
import 'driver.dart';
import 'storage_add.dart';

class OpenlistStorage extends StatefulWidget {
  const OpenlistStorage({super.key});

  @override
  State<OpenlistStorage> createState() => _OpenlistStorageState();
}

class _OpenlistStorageState extends State<OpenlistStorage> {
  dynamic driveI18n;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/common/openlist_i18n/zh-CN/drivers.json').then((value) {
      driveI18n = json.decode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网盘'),
        actions: [
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: const Text('添加'),
                    onTap: () async {
                      await navigateTo(context, const OpenlistDrivers());
                      setState(() {});
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('全部重新加载'),
                    onTap: () async {
                      await showNotification(context, OpenlistClient.storageLoadAll());
                      setState(() {});
                    },
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilderHandler(
          future: OpenlistClient.storageList(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.requireData.length,
              itemBuilder: (context, index) {
                return _buildListTile(context, snapshot.requireData[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, StorageInfo item) {
    return PopupMenuButton(
      offset: const Offset(1, 0),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                await navigateTo(context, OpenlistStorageAdd(initialData: item, driver: item.driver));
                setState(() {});
              },
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.edit_outlined),
                title: Text('编辑'),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                await showNotification(context, OpenlistClient.storageToggle(item.id, item.disabled));
                setState(() {});
              },
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(item.disabled ? Icons.toggle_on_outlined : Icons.toggle_off_outlined),
                title: Text(item.disabled ? '启用' : '禁用'),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                await showNotification(context, OpenlistClient.storageDelete(item.id));
                setState(() {});
              },
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.delete_outline_rounded),
                title: Text('删除'),
              ),
            ),
          ],
      child: ListTile(
        leading:
            item.disabled
                ? const Badge(
                  label: Icon(Icons.pause_rounded, color: Colors.white, size: 14),
                  backgroundColor: Colors.grey,
                )
                : item.status == 'work'
                ? const Badge(
                  label: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                  backgroundColor: Colors.greenAccent,
                )
                : const Badge(
                  label: Icon(Icons.error_outline_rounded, color: Colors.white, size: 14),
                  backgroundColor: Colors.redAccent,
                ),
        title: Text(item.mount_path),
        subtitle: Text(item.status),
        trailing: Text(driveI18n['drivers'][item.driver] ?? item.driver),
      ),
    );
  }
}
