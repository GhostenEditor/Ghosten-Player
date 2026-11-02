import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart ';

class ViewModelConsumer<V extends ViewModelBase<T>, T> extends StatelessWidget {
  const ViewModelConsumer({
    super.key,
    required this.builder,
    this.useScaffold = false,
    this.child,
    this.loadingBuilder,
  });

  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget? child;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    return Consumer<V>(
      builder: (context, viewModel, child) {
        return switch (viewModel.snapshot.connectionState) {
          ConnectionState.none => useScaffold ? Scaffold(appBar: AppBar(), body: const NoData()) : const NoData(),
          ConnectionState.waiting || ConnectionState.active =>
            viewModel.snapshot.hasData
                ? builder(context, viewModel.snapshot.requireData, child)
                : _Loading(useScaffold: useScaffold, loadingBuilder: loadingBuilder),
          ConnectionState.done =>
            viewModel.snapshot.hasData
                ? builder(context, viewModel.snapshot.requireData, child)
                : useScaffold
                ? Scaffold(
                    appBar: AppBar(),
                    body: Center(child: ErrorMessage(error: viewModel.snapshot.error)),
                  )
                : Center(child: ErrorMessage(error: viewModel.snapshot.error)),
        };
      },
      child: child,
    );
  }
}

class ListViewModelConsumer<V extends ListViewModelBase<T>, T> extends StatelessWidget {
  const ListViewModelConsumer({
    super.key,
    required this.builder,
    this.useScaffold = false,
    this.child,
    this.noDataAction,
    this.loadingBuilder,
  });

  final Widget Function(BuildContext context, List<T> value, Widget? child) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget? child;
  final bool useScaffold;
  final Widget? noDataAction;

  @override
  Widget build(BuildContext context) {
    return Consumer<V>(
      builder: (context, viewModel, child) {
        final AsyncSnapshot<List<T>> snapshot = viewModel.snapshot;
        final Widget noData = useScaffold
            ? Scaffold(
                appBar: AppBar(),
                body: NoData(action: noDataAction),
              )
            : NoData(action: noDataAction);
        return switch (snapshot.connectionState) {
          ConnectionState.none => noData,
          ConnectionState.waiting || ConnectionState.active =>
            snapshot.hasData
                ? snapshot.requireData.isNotEmpty
                      ? builder(context, snapshot.requireData, child)
                      : noData
                : _Loading(useScaffold: useScaffold, loadingBuilder: loadingBuilder),
          ConnectionState.done =>
            snapshot.hasData
                ? snapshot.requireData.isNotEmpty
                      ? builder(context, snapshot.requireData, child)
                      : noData
                : useScaffold
                ? Scaffold(
                    appBar: AppBar(),
                    body: Center(child: ErrorMessage(error: snapshot.error)),
                  )
                : Center(child: ErrorMessage(error: snapshot.error)),
        };
      },
      child: child,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.loadingBuilder, this.useScaffold = false});

  final Widget Function(BuildContext context)? loadingBuilder;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    final Widget loading = TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeIn,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child:
          loadingBuilder?.call(context) ??
          LinearProgressIndicator(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          ),
    );
    return useScaffold ? Scaffold(appBar: AppBar(), body: loading) : loading;
  }
}

abstract class ViewModelBase<T> extends ChangeNotifier {
  ViewModelBase() {
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  abstract AsyncSnapshot<T> snapshot;
  bool _disposed = false;

  Future<void> load();

  Widget build();

  @override
  void notifyListeners() {
    if (_disposed) {
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

abstract class ListViewModelBase<T> extends ViewModelBase<List<T>> {
  @override
  abstract AsyncSnapshot<List<T>> snapshot;
}
