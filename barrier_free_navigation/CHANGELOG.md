## 1.0.6

* Added a dedicated "Android Setup" section to the `README.md` to guide users on how to disable the system focus highlight at the theme level (`styles.xml`).
  (안드로이드 시스템 포커스 하이라이트를 테마 레벨(`styles.xml`)에서 비활성화할 수 있도록 `README.md`에 'Android Setup' 섹션을 추가했습니다.)
* Re-implemented `FocusManager.instance.highlightStrategy` to `FocusHighlightStrategy.alwaysTouch` to ensure Flutter's internal focus indicators are hidden by default.
  (플러터 내부의 포커스 인디케이터가 기본적으로 숨겨지도록 `highlightStrategy`를 다시 적용했습니다.)

## 1.0.5

* Disabled the default Android system focus highlight (Ripple effect/Focus indicator) to ensure a consistent barrier-free UI experience.
  (안드로이드 시스템이 키보드 포커스 시 자동으로 그리는 기본 하이라이트(테두리 등)를 비활성화하여, 일관성 있는 배리어프리 사용자 경험을 제공하도록 개선했습니다.)

## 1.0.4

* Added `namespace` to `android/build.gradle` for compatibility with Android Gradle Plugin 8.0 and above.
  (최신 안드로이드 그래들 플러그인(AGP 8.0+) 환경에서의 빌드 호환성을 위해 `namespace` 설정을 추가했습니다.)

## 1.0.3

* Converted the package from a pure Dart package to a Flutter Plugin to support native platform interactions.
  (순수 다트 패키지에서 네이티브 플랫폼 연동을 지원하는 플러터 플러그인(Plugin)으로 전환했습니다.)
* Implemented Android-specific keyboard focus 'kickstart' logic to trigger initial physical key recognition.
  (일부 안드로이드 환경에서 물리 키보드 인식이 지연되던 이슈를 해결하기 위해 초기 킥스타트 로직을 도입했습니다.)
* Updated `BarrierFreeManager.initialize` with an optional `requestInitialFocus` flag (defaulting to `true` on Android).
  (`BarrierFreeManager.initialize` 메서드에 `requestInitialFocus` 옵션을 추가하여 초기 포커스 요청 여부를 제어할 수 있도록 했습니다. (안드로이드 기본값: true))

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
