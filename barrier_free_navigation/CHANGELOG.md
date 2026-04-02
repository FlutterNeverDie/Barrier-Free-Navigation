## 1.0.2

* Added `ChangeNotifier` support to `BarrierFreeManager` for better state observation.
  (`BarrierFreeManager`에 `ChangeNotifier`를 적용하여 상태 변화를 리스닝할 수 있도록 개선했습니다.)
* Exposed several getters in `BarrierFreeManager`: `currentRouteName`, `currentGroupIndex`, `isInitialized`, `isVoiceGuideEnabled`, `currentFocusGroups`, and `focusKeyStack`.
  (`currentRouteName`, `currentGroupIndex` 등 매니저의 주요 상태값들을 외부에 노출했습니다.)
* Added `isDebugEnabled` flag to `BarrierFreeDelegate` and implemented debug logging for route registration/unregistration.
  (`BarrierFreeDelegate`에 디버깅 활성화 플래그를 추가하고, 라우트 등록 및 해제 시 디버그 로그가 출력되도록 구현했습니다.)

## 1.0.1

* Added detailed bilingual (Korean and English) code documentation for models, managers, and widgets.
  (모델, 매니저, 위젯 소스 코드에 상세한 한글 및 영문 주석을 추가했습니다.)

## 1.0.0

* Initial release.
  (초기 릴리즈 버전 퍼블리시)
* Added `BFFocusItem`, `BFAreaFocusGroup`, `BFFocusCoordinator`.
  (`BFFocusItem`, `BFAreaFocusGroup`, `BFFocusCoordinator` 3계층 핵심 위젯 추가)
* Added `BarrierFreeManager` for managing TTS and key events.
  (키보드 입력 이벤트 및 TTS 엔진과의 데이터 전달을 중앙에서 관리하는 `BarrierFreeManager` 추가)
