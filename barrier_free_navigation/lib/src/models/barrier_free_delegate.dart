/// 외부 의존성(TTS 엔진, 효과음 등)을 주입하기 위한 추상 델리게이트 인터페이스
/// Abstract delegate interface to inject external dependencies (TTS engine, sound effects, etc.)
abstract class BarrierFreeDelegate {
  /// TTS로 안내 텍스트를 재생합니다.
  /// Plays the guide text using TTS (Text-To-Speech).
  void speak(String text, {bool isFilter = false});

  /// 사용자가 확인 버튼을 눌렀을 때 재생될 클릭 효과음.
  /// Click sound effect played when the user presses the confirm button.
  void playClickSound();

  /// 음성 안내 기능의 활성화 여부를 반환합니다.
  /// Returns whether the voice guide (TTS) feature is enabled.
  bool get isVoiceGuideEnabled;

  /// 배리어프리 모드 전체의 활성화 여부를 반환합니다.
  /// Returns whether the entire barrier-free mode is enabled.
  bool get isBarrierFreeModeEnabled;

  /// 음량 상승 이벤트 발생 시 호출됩니다.
  /// Called when the volume up event occurs.
  void onVolumeUp() {}

  /// 음량 하강 이벤트 발생 시 호출됩니다.
  /// Called when the volume down event occurs.
  void onVolumeDown() {}

  /// 커스텀 단축키 1 입력 시 호출됩니다.
  /// Called when custom shortcut key 1 is pressed.
  void onCustomKey1() {}

  /// 커스텀 단축키 2 입력 시 호출됩니다.
  /// Called when custom shortcut key 2 is pressed.
  void onCustomKey2() {}
}
