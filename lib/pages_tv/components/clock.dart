import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class Clock extends StatelessWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: formatDate(DateTime.now(), [HH, ':', nn]),
      stream:
          Stream.periodic(const Duration(seconds: 10)).map((_) => formatDate(DateTime.now(), [HH, ':', nn])).distinct(),
      builder:
          (context, snapshot) => Text(
            snapshot.requireData,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
    );
  }
}
