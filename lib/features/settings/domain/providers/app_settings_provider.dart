import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final String? appBackgroundImage;

  const AppSettings({this.appBackgroundImage});

  AppSettings copyWith({String? appBackgroundImage}) {
    return AppSettings(
      appBackgroundImage: appBackgroundImage ?? this.appBackgroundImage,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void setAppBackground(String? url) {
    state = state.copyWith(appBackgroundImage: url);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
