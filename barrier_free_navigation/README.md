# barrier_free_navigation

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) 
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

A highly customizable 3-tier Barrier-Free keyboard navigation package for Flutter.

*(한국어 설명은 아래에 있습니다 / Korean description is below)*

This package provides a systematic way to structure directional focus navigation (up, down, left, right) and text-to-speech (TTS) announcements for visually impaired or motor-impaired users, usually required in Kiosk or remote-control applications.

## Structure

It defines a clear 3-tier structure for focus management:

1. **`BFFocusCoordinator`**: Manages the screen-level flow. It receives keyboard events from the hardware and routes navigation between different structural groups (areas) within a screen.
2. **`BFAreaFocusGroup`**: Represents a distinct visual or functional area (e.g., an App Bar, a List, a Bottom Button Row).
3. **`BFFocusItem`**: An individual focusable widget (e.g., a single Button, a single List Item) wrapped inside an area.

## Android Setup (Important)

In Android 8.0 (API 26) and above, the system may draw a default focus highlight (yellow/green frame) when a physical keyboard is connected. To ensure the best barrier-free experience, it is highly recommended to disable this in your Android theme.

1. Open `android/app/src/main/res/values/styles.xml`.
2. Add or modify your theme (e.g., `NormalTheme`) to include `android:defaultFocusHighlightEnabled`:

```xml
<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <!-- Disable the system default focus highlight -->
    <item name="android:defaultFocusHighlightEnabled">false</item>
    <item name="android:windowBackground">?android:colorBackground</item>
</style>
```

3. Ensure your `AndroidManifest.xml` points to this theme via metadata:

```xml
<meta-data
    android:name="io.flutter.embedding.android.NormalTheme"
    android:resource="@style/NormalTheme"
/>
```

---

## Usage

### 1. Initialize the Manager

Wrap your app or initialize `BarrierFreeManager` with your specific configuration, TTS delegate, and key mapping:

```dart
BarrierFreeManager.instance.initialize(
  delegate: MyTTSDelegate(),
  keyboardConfig: BFKeyboardConfig(
    upKey: PhysicalKeyboardKey.arrowUp,
    downKey: PhysicalKeyboardKey.arrowDown,
    leftKey: PhysicalKeyboardKey.arrowLeft,
    rightKey: PhysicalKeyboardKey.arrowRight,
    enterKey: PhysicalKeyboardKey.enter,
    // Add any extra custom actions if needed
    backKey: PhysicalKeyboardKey.escape,
    callStaffKey: PhysicalKeyboardKey.f1,
  ),
);
```

### 2. Implement the Delegate

You must provide a `BarrierFreeDelegate` to handle actual TTS capabilities.

```dart
class MyTTSDelegate implements BarrierFreeDelegate {
  @override
  void speak(String text, {bool isFilter = true}) {
    // Your TTS implementation here
    // e.g., FlutterTts().speak(text);
  }

  @override
  void stop() {
    // Stop TTS
  }
}
```

### 3. Wrap your UI 

Wrap your structural screens with `BFFocusCoordinator`, define your groups via `BFAreaFocusGroup`, and mark interactive elements as `BFFocusItem`.

```dart
BFFocusCoordinator(
  routeName: '/exampleScreen',
  focusGroups: [
    FocusGroupConfig(focusNode: _group1Focus, isSingleChild: false),
    FocusGroupConfig(focusNode: _group2Focus, isSingleChild: true),
  ],
  child: Column(
    children: [
      BFAreaFocusGroup(
        focusNode: _group1Focus,
        ttsMsg: 'Top Navigation Group',
        child: Row(
          children: [
            BFFocusItem(
              ttsMsg: 'Home Button',
              onTap: () => print('Home'),
              child: Icon(Icons.home),
            ),
            BFFocusItem(
              ttsMsg: 'Settings Button',
              onTap: () => print('Settings'),
              child: Icon(Icons.settings),
            ),
          ],
        ),
      ),
      BFAreaFocusGroup(
        focusNode: _group2Focus,
        ttsMsg: 'Main Content Area',
        child: BFFocusItem( // Since isSingleChild is true above
          ttsMsg: 'Main Submit Button',
          onTap: () => print('Submit'),
          child: Text('Submit'),
        ),
      ),
    ],
  ),
)
```

## How It Works

1. Users press `left/right` to move horizontally between `BFFocusItem`s inside a `BFAreaFocusGroup`.
2. Users press `up/down` to jump to the previous/next `BFAreaFocusGroup`.
3. Whenever an element gains focus, `BarrierFreeManager` automatically calls your TTS delegate.
4. Users press `enter` to trigger the `onTap` functionality of the currently focused item.

---

# (한국어) barrier_free_navigation

Flutter용 고도화된 3단계 배리어 프리(Barrier-Free) 키보드 내비게이션 패키지입니다.

시각/지체 장애인을 위한 배리어 프리 정보통신기기(키오스크 등) 표준을 준수하거나 리모컨으로 제어되는 앱을 개발할 때, 상하좌우 방향키(물리 키패드)를 통한 초점 이동과 음성 안내(TTS, Text-to-Speech)를 체계적으로 관리할 수 있도록 도와줍니다.

## 구조 (3-Tier Architecture)

포커스 관리를 위해 다음과 같은 3계층 구조를 사용합니다:

1. **`BFFocusCoordinator` (화면 단위 코디네이터)**: 화면 최상단에서 하드웨어 키보드 이벤트를 받아, 등록된 여러 포커스 그룹 간의 포커스 이동 흐름을 제어합니다.
2. **`BFAreaFocusGroup` (영역/그룹 단위)**: 디자인이나 기능 상 분리되는 큰 덩어리(예: 상단 앱바, 메인 리스트 뷰, 화면 하단 버튼 영역 등) 단위로 감싸줍니다.
3. **`BFFocusItem` (개별 아이템 단위)**: 포커스를 받아야 하는 개별 위젯(버튼, 리스트 아이템)을 감싸주며, 실제 클릭 이벤트(`onTap`)와 TTS 메시지(`ttsMsg`)를 담당합니다.

## 안드로이드 설정 가이드 (중요)

안드로이드 8.0(API 26) 이상의 기기에서는 하드웨어 키보드가 연결되었을 때 시스템이 자동으로 기본 포커스 하이라이트(노란색/연두색 테두리)를 그릴 수 있습니다. 일관성 있는 배리어프리 사용자 경험을 위해 가급적 이 기능을 테마에서 비활성화하는 것을 권장합니다.

1. `android/app/src/main/res/values/styles.xml` 파일을 엽니다.
2. 사용 중인 테마(예: `NormalTheme`)에 `android:defaultFocusHighlightEnabled` 속성을 추가합니다:

```xml
<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <!-- 시스템 기본 포커스 하이라이트 비활성화 -->
    <item name="android:defaultFocusHighlightEnabled">false</item>
    <item name="android:windowBackground">?android:colorBackground</item>
</style>
```

3. `AndroidManifest.xml`에서 해당 테마를 메타데이터로 참조하고 있는지 확인합니다:

```xml
<meta-data
    android:name="io.flutter.embedding.android.NormalTheme"
    android:resource="@style/NormalTheme"
/>
```

---

## 작동 방식

1. 사용자가 키패드의 **좌/우 방향키**를 누르면 같은 `BFAreaFocusGroup`(동일 영역) 내의 `BFFocusItem` 간 이동이 발생합니다.
2. 사용자가 **상/하 방향키**를 누르면 이전/다음 `BFAreaFocusGroup` 영역 전체 단위로 크게 포커스가 점프합니다. (예: 상단 헤더 -> 메인 컨텐츠 -> 하단 버튼)
3. 특정 아이템이나 영역에 포커스가 도착할 때마다, `BarrierFreeManager`를 통해 미리 등록해둔 TTS 델리게이트가 자동으로 `ttsMsg`를 읽어줍니다.
4. **확인(Enter) 키**를 누르면 현재 포커스 중인 `BFFocusItem`의 `onTap` 동작이 실행됩니다.

## 커스텀 키패드 제어 (Kiosk 특화 기능)

단순한 상하좌우 및 엔터 이외에도, 키오스크 장비에 탑재된 특수 하드웨어 키(예: 뒤로 가기, 직원 호출, 볼륨 제어 등)를 자유롭게 맵핑할 수 있습니다.

```dart
BarrierFreeManager.instance.addCustomActionCallback((action) {
  if (action == BFCustomAction.back) {
    Navigator.pop(context);
  } else if (action == BFCustomAction.callStaff) {
    // 직원 호출 로직 실행
  } else if (action == BFCustomAction.volumeUp) {
    // 볼륨업 작동
  }
});
```
