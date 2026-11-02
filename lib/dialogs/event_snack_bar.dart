import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../adaptive/adaptive.dart';
import '../components/components.dart ';

enum _SnackStatus { done, error, pause, loading }

class EventSnackBar extends StatelessWidget {
  const EventSnackBar({super.key, required this.stream});

  final Stream<ScheduleTaskEventData> stream;
  static ScheduleTaskEventData? _initialData;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: switch (Theme.brightnessOf(context)) {
        Brightness.dark => lightTheme,
        Brightness.light => darkTheme,
      },
      child: StreamBuilder(
        initialData: _initialData,
        stream: stream,
        builder: (context, snapshot) {
          late _SnackStatus status;
          Widget? title;
          Widget? content;

          if (snapshot.hasData) {
            final ScheduleTaskEventData data = snapshot.requireData;
            _initialData = data;
            switch (data.type) {
              case ScheduleTaskEventType.syncLibrary:
                final d = data.data as List<dynamic>;
                switch (data.subType) {
                  case ScheduleTaskEventStatus.idle:
                    status = _SnackStatus.pause;
                    title = const Text('媒体库同步开始');
                  case ScheduleTaskEventStatus.update:
                    status = _SnackStatus.loading;
                    title = const Text('媒体库同步中');
                    content = Text('已同步 ${d[0]} 个文件');
                  case ScheduleTaskEventStatus.done:
                    status = _SnackStatus.done;
                    title = const Text('媒体库同步完成');
                    content = Text('已同步 ${d[0]} 个文件');
                  case ScheduleTaskEventStatus.error:
                    status = _SnackStatus.error;
                    title = const Text('媒体库同步失败');
                    content = Text('已同步 ${d[0]} 个文件');
                }
              case ScheduleTaskEventType.scrapeLibrary:
                final d = data.data as List<dynamic>;
                switch (data.subType) {
                  case ScheduleTaskEventStatus.idle:
                    status = _SnackStatus.pause;
                    title = const Text('媒体库刮削开始');
                  case ScheduleTaskEventStatus.update:
                    status = _SnackStatus.loading;
                    title = const Text('媒体库刮削同步中');
                    content = Text('正在刮削 ${d[1]}');
                  case ScheduleTaskEventStatus.done:
                    status = _SnackStatus.done;
                    title = const Text('媒体库刮削完成');
                    content = Text('已刮削 ${d[0]} 个媒体');
                  case ScheduleTaskEventStatus.error:
                    status = _SnackStatus.error;
                    title = const Text('媒体库刮削失败');
                    content = Text('已刮削 ${d[0]} 个媒体');
                }
              case ScheduleTaskEventType.palette:
                final count = data.data as int;
                switch (data.subType) {
                  case ScheduleTaskEventStatus.idle:
                    status = _SnackStatus.pause;
                    title = const Text('获取主题色开始');
                  case ScheduleTaskEventStatus.update:
                    status = _SnackStatus.loading;
                    title = const Text('获取主题色中');
                    content = Text('已获取 $count');
                  case ScheduleTaskEventStatus.done:
                    status = _SnackStatus.done;
                    title = const Text('获取主题色完成');
                    content = Text('已获取 $count');
                  case ScheduleTaskEventStatus.error:
                    status = _SnackStatus.error;
                    title = const Text('媒体库刮削失败');
                    content = Text('已获取 $count');
                }
            }
          } else if (snapshot.hasError) {
            status = _SnackStatus.error;
            content = ErrorMessage(error: snapshot.error);
          } else {
            status = .loading;
          }

          return Row(
            spacing: 16,
            children: [
              switch (status) {
                _SnackStatus.done => const Icon(Icons.check_circle, color: Colors.lightGreen),
                _SnackStatus.error => Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                _SnackStatus.pause => const Icon(Icons.pause_rounded),
                _SnackStatus.loading => const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              },
              Expanded(
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: 2,
                  children: [
                    if (title != null) DefaultTextStyle(style: Theme.of(context).textTheme.titleSmall!, child: title),
                    if (content != null)
                      DefaultTextStyle(style: Theme.of(context).textTheme.bodySmall!, child: content),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
