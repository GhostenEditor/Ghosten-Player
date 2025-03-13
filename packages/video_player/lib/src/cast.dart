import '../player.dart';

abstract class Cast {
  Stream<List<CastDevice>> discover();

  const Cast();
}

abstract class CastDevice implements PlayerBaseController {
  final String friendlyName;
  final String id;

  const CastDevice({
    required this.id,
    required this.friendlyName,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> start();

  Future<void> stop();

  Future<void> seek(Duration seek);

  Future<double> getVolume();

  Future<void> setUrl(Uri uri, {String? title, String playType = 'video'});

  Future<void> setVolume(double volume);

  Future<dynamic> getMediaInfo();

  Future<dynamic> getTransportInfo();
}
