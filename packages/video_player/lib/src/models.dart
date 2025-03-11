import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum PlayerStatus {
  playing,
  buffering,
  paused,
  ended,
  error,
  idle;

  static PlayerStatus fromString(String str) {
    return PlayerStatus.values.firstWhere((element) => element.name == str);
  }
}

class MediaTrack {
  String? label;
  String? id;
  String type;
  bool selected;

  MediaTrack.fromJson(dynamic json)
      : label = json['label'],
        id = json['id'],
        type = json['type'],
        selected = json['selected'];
}

class MediaTrackGroup {
  final List<MediaTrack> video;
  final List<MediaTrack> audio;
  final List<MediaTrack> sub;

  dynamic selectedVideo;
  dynamic selectedAudio;
  dynamic selectedSub;

  MediaTrackGroup({required this.video, required this.sub, required this.audio}) {
    selectedVideo = video.firstWhereOrNull((e) => e.selected)?.id;
    selectedAudio = audio.firstWhereOrNull((e) => e.selected)?.id;
    selectedSub = sub.firstWhereOrNull((e) => e.selected)?.id;
  }

  MediaTrackGroup.empty()
      : video = [],
        sub = [],
        audio = [];

  MediaTrackGroup.fromTracks(List<MediaTrack> tracks)
      : audio = tracks.where((track) => track.type == 'audio').toList(),
        video = tracks.where((track) => track.type == 'video').toList(),
        sub = tracks.where((track) => track.type == 'sub').toList(),
        selectedVideo = tracks.firstWhereOrNull((track) => track.type == 'video' && track.selected)?.id,
        selectedAudio = tracks.firstWhereOrNull((track) => track.type == 'audio' && track.selected)?.id,
        selectedSub = tracks.firstWhereOrNull((track) => track.type == 'sub' && track.selected)?.id;
}

class MediaChange {
  final int index;
  final Duration position;

  MediaChange.fromJson(dynamic json)
      : index = json['index'],
        position = Duration(milliseconds: json['position']);
}

class MediaInfo {
  final String? videoCodecs;
  final String? videoMime;
  final double? videoFPS;
  final int? videoBitrate;
  final String? videoSize;
  final String? audioCodecs;
  final String? audioMime;
  final int? audioBitrate;

  MediaInfo.fromJson(dynamic json)
      : videoCodecs = json['videoCodecs'],
        videoMime = json['videoMime'],
        videoFPS = json['videoFPS'],
        videoSize = json['videoSize'],
        videoBitrate = json['videoBitrate'],
        audioCodecs = json['audioCodecs'],
        audioMime = json['audioMime'],
        audioBitrate = json['audioBitrate'];
}

enum AspectRatioType {
  auto,
  fill,
  a16_9,
  a4_3,
  a1_1;

  double? value(BuildContext context) {
    return switch (this) {
      AspectRatioType.auto => null,
      AspectRatioType.fill => MediaQuery.of(context).size.aspectRatio,
      AspectRatioType.a16_9 => 1.778,
      AspectRatioType.a4_3 => 1.333,
      AspectRatioType.a1_1 => 1.0,
    };
  }

  String label(BuildContext context) {
    return switch (this) {
      AspectRatioType.auto => 'Fit',
      AspectRatioType.fill => 'Fill',
      AspectRatioType.a16_9 => '16 / 9',
      AspectRatioType.a4_3 => '4 / 3',
      AspectRatioType.a1_1 => '1 / 1',
    };
  }
}

enum PlaylistItemSourceType {
  local,
  hls,
  other,
}

class PlaylistItem<T> {
  final String? poster;
  final String? title;
  final String? description;
  final Uri url;
  final Duration start;
  final Duration end;
  final PlaylistItemSourceType sourceType;
  final List<Subtitle>? subtitles;
  final T source;

  const PlaylistItem({
    required this.url,
    required this.sourceType,
    required this.source,
    this.title,
    this.description,
    this.poster,
    this.subtitles,
    this.start = Duration.zero,
    this.end = Duration.zero,
  });

  PlaylistItem<T> copyWith({
    String? poster,
    String? title,
    String? description,
    Uri? url,
    Duration? start,
    Duration? end,
    PlaylistItemSourceType? sourceType,
    List<Subtitle>? subtitles,
  }) {
    return PlaylistItem(
      poster: poster ?? this.poster,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      start: start ?? this.start,
      end: end ?? this.end,
      sourceType: sourceType ?? this.sourceType,
      subtitles: subtitles ?? this.subtitles,
      source: source,
    );
  }

  Map<String, dynamic> toSource() {
    return {
      'type': sourceType.name,
      'url': url.toString(),
      'title': title,
      'description': description,
      'poster': poster,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
      'subtitle': subtitles?.map((e) => e.toJson()).toList()
    };
  }

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(Object other) => other is PlaylistItem && url == other.url && title == other.title && url == other.url;
}

enum SubtitleMimeType {
  xml,
  vtt,
  ass,
  srt;

  static SubtitleMimeType? fromString(String? str) {
    return SubtitleMimeType.values.firstWhereOrNull((element) => element.name == str);
  }
}

class Subtitle {
  final Uri url;
  final SubtitleMimeType mimeType;
  final String? language;

  const Subtitle({required this.url, required this.mimeType, this.language});

  Map<String, dynamic> toJson() {
    return {
      'url': url.toString(),
      'mimeType': mimeType.name,
      'language': language,
    };
  }
}
