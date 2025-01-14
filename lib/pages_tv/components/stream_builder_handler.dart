import 'package:flutter/material.dart';

import '../../components/error_message.dart';
import 'loading.dart';

class StreamBuilderHandler<T> extends StatelessWidget {
  final AsyncWidgetBuilder<T> builder;
  final Stream<T>? stream;
  final T? initialData;

  const StreamBuilderHandler({super.key, required this.builder, this.stream, this.initialData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialData,
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: snapshot.hasError ? ErrorMessage(snapshot: snapshot) : const Loading());
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.done:
            return snapshot.hasError
                ? Center(child: ErrorMessage(snapshot: snapshot))
                : snapshot.hasData
                    ? builder(context, snapshot)
                    : const SizedBox();
        }
      },
    );
  }
}

class StreamBuilderSliverHandler<T> extends StatelessWidget {
  final AsyncWidgetBuilder<T> builder;
  final Stream<T>? stream;
  final T? initialData;

  const StreamBuilderSliverHandler({super.key, required this.builder, this.stream, this.initialData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialData,
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return snapshot.hasError
                ? SliverToBoxAdapter(child: Center(child: ErrorMessage(snapshot: snapshot)))
                : snapshot.hasData
                    ? builder(context, snapshot)
                    : const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.done:
            return snapshot.hasError
                ? SliverFillRemaining(child: Center(child: ErrorMessage(snapshot: snapshot)))
                : snapshot.hasData
                    ? builder(context, snapshot)
                    : const SliverToBoxAdapter();
        }
      },
    );
  }
}
