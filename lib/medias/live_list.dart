import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../menus/playlist.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../components/components.dart ';
import '../extensions/extensions.dart';
import '../routers.dart';
import '../view_models/view_models.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});

  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late Orientation _orientation = MediaQuery.orientationOf(context);

  @override
  Widget build(BuildContext context) {
    _orientation = MediaQuery.orientationOf(context);
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return Padding(
      padding: theme.channelsContentPadding,
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: ListViewModelConsumer<LiveListViewModel, Playlist>(
              loadingBuilder: (context) => const SafeArea(child: Center(child: Loading())),
              noDataAction: IconButton.filledTonal(
                onPressed: () => context.pushNamed(.liveEdit),
                autofocus: true,
                icon: const Icon(Icons.add),
              ),
              builder: (context, items, _) {
                return CustomScrollView(
                  slivers: [
                    SliverSafeArea(
                      bottom: false,
                      sliver: SliverPadding(
                        padding: theme.channelsListViewPadding,
                        sliver: SliverList.separated(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final Playlist item = items[index];
                            return ActionListTile(
                              // selected: widget.onSelected != null && _selectedPlaylistId == item.id,
                              autofocus: index == 0,
                              title: item.title == null ? null : Text(item.title!, overflow: TextOverflow.ellipsis),
                              subtitle: Text(item.url, overflow: TextOverflow.ellipsis),
                              onTap: () => (_orientation == .portrait ? context : _navigatorKey.currentContext)
                                  ?.pushNamed(.liveDetail, arguments: item),
                              actionSide: ActionSide.start,
                              actions: PlaylistMenu(item),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4),
                        ),
                      ),
                    ),
                    SliverSafeArea(
                      top: false,
                      sliver: SliverPadding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + theme.channelsListViewPadding.bottom,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton.filledTonal(
                                onPressed: () => context.pushNamed(.liveEdit),
                                icon: const Icon(Icons.add),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_orientation == .landscape) const VerticalDivider(width: 1, indent: 0, endIndent: 0),
          if (_orientation == .landscape)
            Flexible(
              flex: 3,
              child: AppNavigator(
                navigatorKey: _navigatorKey,
                routeDirectionalTraversalEdgeBehavior: .parentScope,
                onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const SizedBox()),
                onGenerateRoute: onGenerateRoute,
              ),
            ),
        ],
      ),
    );
  }
}
