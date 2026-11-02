import 'package:flutter/material.dart';

import 'error_message.dart';
import 'loading.dart';

class StreamBuilderHandler<T> extends StatelessWidget {
  const StreamBuilderHandler({super.key, required this.builder, this.stream, this.initialData});

  final AsyncWidgetBuilder<T> builder;
  final Stream<T>? stream;
  final T? initialData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialData,
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: snapshot.hasError ? ErrorMessage(error: snapshot.error) : const Loading());
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.done:
            return snapshot.hasError
                ? Center(child: ErrorMessage(error: snapshot.error))
                : snapshot.hasData
                ? builder(context, snapshot)
                : const SizedBox();
        }
      },
    );
  }
}
