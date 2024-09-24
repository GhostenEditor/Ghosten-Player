import 'package:flutter/material.dart';

import 'error_message.dart';

class FutureBuilderHandler<T> extends StatelessWidget {
  final AsyncWidgetBuilder<T> builder;
  final Future<T>? future;
  final T? initialData;

  const FutureBuilderHandler({super.key, required this.builder, this.future, this.initialData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: initialData,
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError ? Center(child: ErrorMessage(snapshot: snapshot)) : builder(context, snapshot);
        } else {
          return snapshot.hasData ? builder(context, snapshot) : const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class FutureBuilderSliverHandler<T> extends StatelessWidget {
  final AsyncWidgetBuilder<T> builder;
  final Future<T>? future;
  final T? initialData;

  const FutureBuilderSliverHandler({super.key, required this.builder, this.future, this.initialData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: initialData,
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError ? SliverFillRemaining(child: Center(child: ErrorMessage(snapshot: snapshot))) : builder(context, snapshot);
        } else {
          return snapshot.hasData ? builder(context, snapshot) : const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
