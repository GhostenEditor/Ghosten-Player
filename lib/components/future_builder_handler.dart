import 'package:flutter/material.dart';

import 'error_message.dart';

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
          return snapshot.hasData ? builder(context, snapshot) : const Center(child: CircularProgressIndicator());
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
    this.loading = const Center(child: CircularProgressIndicator()),
  });

  final AsyncWidgetBuilder<T> builder;
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
          return snapshot.hasError ? SliverFillRemaining(child: Center(child: ErrorMessage(error: snapshot.error))) : builder(context, snapshot);
        } else {
          return snapshot.hasData ? builder(context, snapshot) : SliverFillRemaining(child: loading);
        }
      },
    );
  }
}
