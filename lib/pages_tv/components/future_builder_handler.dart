import 'package:flutter/material.dart';

import '../../components/error_message.dart';
import '../components/loading.dart';

class FutureBuilderHandler<T> extends StatelessWidget {
  const FutureBuilderHandler({super.key, required this.builder, this.future, this.initialData});

  final AsyncWidgetBuilder<T> builder;
  final Future<T>? future;
  final T? initialData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: initialData,
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError ? Center(child: ErrorMessage(error: snapshot.error)) : builder(context, snapshot);
        } else {
          return snapshot.hasData ? builder(context, snapshot) : const Loading();
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
                  ? SliverToBoxAdapter(child: errorBuilder!(context, snapshot))
                  : SliverFillRemaining(hasScrollBody: false, child: Center(child: ErrorMessage(error: snapshot.error)))
              : builder(context, snapshot);
        } else {
          return snapshot.hasData
              ? builder(context, snapshot)
              : loadingBuilder != null
              ? SliverToBoxAdapter(child: loadingBuilder!(context, snapshot))
              : const SliverFillRemaining(hasScrollBody: false, child: Loading());
        }
      },
    );
  }
}
