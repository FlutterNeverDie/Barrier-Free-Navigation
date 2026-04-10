## 1.1.2

* **[Feature]** Added `previousRouteName` getter to `BarrierFreeManager`. This allows developers to check the previous route name in the navigation stack (useful for breadcrumbs or back-navigation logic).
* **[KR]** `BarrierFreeManager`에 `previousRouteName` 게터 추가: 현재 활성화된 화면 바로 이전의 라우트 이름을 확인할 수 있는 기능을 추가했습니다. (히스토리 추적 및 네비게이션 분기 로직에 활용 가능)

## 1.1.1

* **[Optimization]** `registerFocusGroups` 안정성 개선: 이미 등록된 라우트가 재호출될 경우 스택 순서를 변경하지 않도록 수정하여, 백그라운드 화면 리빌드 시 포커스 스택이 뒤섞이거나 인덱스가 0으로 초기화되는 버그를 해결했습니다.
* **[Documentation]** `README.md` 한국어 가이드 대폭 강화 (3계층 아키텍처 설명, 안드로이드 전용 `styles.xml` 설정 가이드 추가 등).
* **[Optimization]** Enhanced `registerFocusGroups` stability: Prevents focus stack re-ordering during background widget rebuilds, ensuring focus index and active route integrity.
* **[Documentation]** Significantly improved Documentation (Korean focused) with detailed setup guides and Android-specific configuration.

## 1.0.8

* Improved README.md with more detailed code examples and customization guides.
* [KR] 상세한 사용 예시 및 테마 커스터마이징 가이드를 포함하여 `README.md` 문서를 개선했습니다.

## 1.0.7

* Added `focusColor` and `areaFocusColor` to `BarrierFreeDelegate` and `BarrierFreeManager` for visual customization.
* Updated `BFAreaFocusGroup` and `BFFocusItem` to support dynamic focus border colors (e.g., Theme aware).
* [KR] 포커스 테두리 색상 커스터마이징 기능 추가 (BarrierFreeDelegate를 통해 다크/라이트 모드 등 동적 색상 대응)
* [KR] 영역(Area) 및 개별 아이템(Item)의 테두리 색상을 매니저를 통해 중앙 제어하도록 개선

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
