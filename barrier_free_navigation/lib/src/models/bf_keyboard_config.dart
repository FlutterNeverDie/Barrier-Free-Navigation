import 'package:flutter/services.dart';

/// 배리어프리 네비게이션을 위한 물리 키보드 매핑 설정 클래스
/// Physical keyboard mapping configuration class for barrier-free navigation
class BFKeyboardConfig {
  /// 다음 그룹(영역)으로 이동하는 키 (보통 상승/이전 그룹 역할)
  /// Key to move to the next group/area (usually acts as UP/previous group)
  final PhysicalKeyboardKey groupUpKey;

  /// 이전 그룹(영역)으로 이동하는 키 (보통 하강/다음 그룹 역할)
  /// Key to move to the previous group/area (usually acts as DOWN/next group)
  final PhysicalKeyboardKey groupDownKey;

  /// 그룹 내의 이전 아이템으로 이동하는 키 (보통 좌측 이동 역할을 수행)
  /// Key to move to the previous item within a group (usually moves LEFT)
  final PhysicalKeyboardKey itemPreviousKey;

  /// 그룹 내의 다음 아이템으로 이동하는 키 (보통 우측 이동 역할을 수행)
  /// Key to move to the next item within a group (usually moves RIGHT)
  final PhysicalKeyboardKey itemNextKey;

  /// 아이템의 동작(onTap)을 실행하는 확인 키
  /// Confirm key to execute the item's action (usually ENTER)
  final PhysicalKeyboardKey enterKey;

  /// 볼륨 올림 키
  /// Volume up key
  final PhysicalKeyboardKey volumeUpKey;

  /// 볼륨 내림 키
  /// Volume down key
  final PhysicalKeyboardKey volumeDownKey;

  /// 커스텀 동작 키 1
  /// Custom action key 1
  final PhysicalKeyboardKey customKey1;

  /// 커스텀 동작 키 2
  /// Custom action key 2
  final PhysicalKeyboardKey customKey2;

  /// 기본 제공 단축키 이외의 앱 별도 처리 키보드 이벤트를 핸들링할 콜백
  /// `true` 반환 시 이벤트를 소모했다고 판단 (차단)
  /// Callback to handle app-specific keyboard events other than default shortcuts.
  /// If it returns `true`, the event is considered consumed (blocked).
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

  /// Kiosk v3에서 사용 중이던 기본 키 설정 팩토리
  /// Default key configuration factory used in Kiosk v3
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
