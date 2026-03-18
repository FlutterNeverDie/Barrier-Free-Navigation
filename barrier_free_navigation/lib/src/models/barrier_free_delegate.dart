abstract class BarrierFreeDelegate {
  /// TTS로 안내 텍스트를 재생합니다.
  void speak(String text, {bool isFilter = false});

  /// 사용자가 확인 버튼을 눌렀을 때 재생될 클릭 효과음.
  void playClickSound();

  /// 음성 안내 활성화 여부를 반환합니다.
  bool get isVoiceGuideEnabled;

  /// 배리어프리 모드 전체의 활성화 여부를 반환합니다.
  bool get isBarrierFreeModeEnabled;

  /// 음량 상승
  void onVolumeUp() {}

  /// 음량 하강
  void onVolumeDown() {}

  /// 커스텀 키 1
  void onCustomKey1() {}

  /// 커스텀 키 2
  void onCustomKey2() {}
}
