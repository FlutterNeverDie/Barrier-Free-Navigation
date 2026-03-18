import 'package:flutter/services.dart';

class BFKeyboardConfig {
  final PhysicalKeyboardKey groupUpKey;
  final PhysicalKeyboardKey groupDownKey;
  final PhysicalKeyboardKey itemPreviousKey;
  final PhysicalKeyboardKey itemNextKey;
  final PhysicalKeyboardKey enterKey;
  final PhysicalKeyboardKey volumeUpKey;
  final PhysicalKeyboardKey volumeDownKey;
  final PhysicalKeyboardKey customKey1;
  final PhysicalKeyboardKey customKey2;

  /// 기본 제공 단축키 이외의 앱 별도 처리 키보드 이벤트를 핸들링할 콜백
  /// `true` 반환 시 이벤트를 소모했다고 판단 (차단)
  final bool Function(PhysicalKeyboardKey key)? onCustomAppKeyEvent;

  const BFKeyboardConfig({
    required this.groupUpKey,
    required this.groupDownKey,
    required this.itemPreviousKey,
    required this.itemNextKey,
    required this.enterKey,
    required this.volumeUpKey,
    required this.volumeDownKey,
    required this.customKey1,
    required this.customKey2,
    this.onCustomAppKeyEvent,
  });

  /// Kiosk v3에서 사용 중이던 기본 키
  factory BFKeyboardConfig.defaultKeys() {
    return const BFKeyboardConfig(
      groupUpKey: PhysicalKeyboardKey.f17,
      groupDownKey: PhysicalKeyboardKey.f18,
      itemPreviousKey: PhysicalKeyboardKey.f19,
      itemNextKey: PhysicalKeyboardKey.f20,
      enterKey: PhysicalKeyboardKey.enter,
      volumeUpKey: PhysicalKeyboardKey.audioVolumeUp,
      volumeDownKey: PhysicalKeyboardKey.audioVolumeDown,
      customKey1: PhysicalKeyboardKey.f24,
      customKey2: PhysicalKeyboardKey.f23,
    );
  }
}
