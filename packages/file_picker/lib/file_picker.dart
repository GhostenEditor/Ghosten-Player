import 'src/file_picker_platform_interface.dart';

export 'src/models.dart';

class FilePicker {
  static final externalStoragePath = FilePickerPlatform.instance.externalStoragePath;
  static final moviePath = FilePickerPlatform.instance.moviePath;
  static final musicPath = FilePickerPlatform.instance.musicPath;
  static final downloadPath = FilePickerPlatform.instance.downloadPath;
  static final cachePath = FilePickerPlatform.instance.cachePath;
  static final showFilePicker = FilePickerPlatform.instance.showFilePicker;
  static final externalUsbStorages = FilePickerPlatform.instance.externalUsbStorages;
}
