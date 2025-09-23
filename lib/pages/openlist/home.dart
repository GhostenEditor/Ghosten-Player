import 'package:flutter/material.dart';

import 'file.dart';
import 'setting.dart';
import 'storage.dart';
import 'web.dart';

class OpenlistHome extends StatefulWidget {
  const OpenlistHome({super.key});

  @override
  State<OpenlistHome> createState() => _OpenlistHomeState();
}

class _OpenlistHomeState extends State<OpenlistHome> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _activeIndex,
        onDestinationSelected: (index) => setState(() => _activeIndex = index),
        destinations: [
          NavigationDestination(
            icon: _activeIndex == 0 ? const Icon(Icons.menu_rounded) : const Icon(Icons.menu_outlined),
            label: '目录',
          ),
          NavigationDestination(
            icon: _activeIndex == 1 ? const Icon(Icons.inventory_2) : const Icon(Icons.inventory_2_outlined),
            label: '网盘',
          ),
          NavigationDestination(
            icon: _activeIndex == 2 ? const Icon(Icons.web) : const Icon(Icons.web_outlined),
            label: '网页',
          ),
          NavigationDestination(
            icon: _activeIndex == 3 ? const Icon(Icons.settings) : const Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
      ),
      body: switch (_activeIndex) {
        0 => const OpenlistFile(),
        1 => const OpenlistStorage(),
        2 => const OpenlistWeb(),
        3 => const OpenlistSetting(),
        _ => throw UnimplementedError(),
      },
    );
  }
}
