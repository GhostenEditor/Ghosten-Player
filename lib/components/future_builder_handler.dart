import 'package:flutter/material.dart';

import '../pages/components/loading.dart';
import 'error_message.dart';

class FutureBuilderHandler<T> extends StatelessWidget {
  const FutureBuilderHandler({
    super.key,
    required this.builder,
    this.future,
    this.initialData,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final AsyncWidgetBuilder<T> builder;
  final AsyncWidgetBuilder<T>? errorBuilder;
  final AsyncWidgetBuilder<T>? loadingBuilder;
  final Future<T>? future;
  final T? initialData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: initialData,
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError
              ? errorBuilder != null
                  ? errorBuilder!(context, snapshot)
                  : Center(child: ErrorMessage(error: snapshot.error))
              : builder(context, snapshot);
        } else {
          return snapshot.hasData
              ? builder(context, snapshot)
              : loadingBuilder != null
              ? loadingBuilder!(context, snapshot)
              : const Center(child: Loading());
        }
      },
    );
  }
}

class FutureBuilderSliverHandler<T> extends StatelessWidget {
  const FutureBuilderSliverHandler({
    super.key,
    required this.builder,
    this.future,
    this.initialData,
    this.loading = const Center(child: Loading()),
    this.errorBuilder,
    this.loadingBuilder,
    this.fillRemaining = false,
  });

  final AsyncWidgetBuilder<T> builder;
  final AsyncWidgetBuilder<T>? errorBuilder;
  final AsyncWidgetBuilder<T>? loadingBuilder;
  final bool fillRemaining;
  final Future<T>? future;
  final T? initialData;
  final Widget loading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: initialData,
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError
              ? errorBuilder != null
                  ? fillRemaining
                      ? SliverFillRemaining(child: errorBuilder!(context, snapshot))
                      : SliverToBoxAdapter(child: errorBuilder!(context, snapshot))
                  : fillRemaining
                  ? SliverFillRemaining(child: Center(child: ErrorMessage(error: snapshot.error)))
                  : SliverToBoxAdapter(child: Center(child: ErrorMessage(error: snapshot.error)))
              : builder(context, snapshot);
        } else {
          return snapshot.hasData
              ? builder(context, snapshot)
              : loadingBuilder != null
              ? fillRemaining
                  ? SliverFillRemaining(child: loadingBuilder!(context, snapshot))
                  : SliverToBoxAdapter(child: loadingBuilder!(context, snapshot))
              : fillRemaining
              ? SliverFillRemaining(child: Center(child: loading))
              : SliverToBoxAdapter(child: Center(child: loading));
        }
      },
    );
  }
}
