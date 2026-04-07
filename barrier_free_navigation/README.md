# barrier_free_navigation

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) 
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Pub Version](https://img.shields.io/pub/v/barrier_free_navigation?label=pub.dev&color=blue)

A professional, 3-tier **Barrier-Free** navigation system for Flutter.  
*Perfect for Kiosks, Remote-controlled apps (STB), and accessibility-focused interfaces.*

*(한국어 설명은 아래에 있습니다 / Korean description is below)*

---

## 🌟 Why use this package?

Navigating with physical keys (arrows, enter) in Flutter can be frustrating when layouts are complex. This package provides:
- **Hierarchical Navigation**: Group focusable items for logical "Area focus" (jumps between larger sections).
- **Embedded TTS Logic**: Automatically triggers your Text-to-Speech delegate when focus moves.
- **Visual Clarity**: Highly customizable focus borders that work outside of standard Material highlights.
- **Kiosk-Ready**: Native Android setup tips for a clean UI without unwanted system focus boxes.

---

## 🏗️ The 3-Tier Architecture

| Component | Responsibility |
| :--- | :--- |
| **`BFFocusCoordinator`** | **Page Level**. Manages the navigation flow and hardware key listeners for the entire screen. |
| **`BFAreaFocusGroup`** | **Section Level**. Groups items together (e.g., AppBar, Sidebar). Allows users to "jump" sections with Up/Down keys. |
| **`BFFocusItem`** | **Item Level**. The final interactive node (e.g., Button). Handles horizontal navigation within its Group. |

---

## 🚀 Getting Started

### 1. Initialize the Manager
At the root of your application (usually in `main.dart`), initialize the `BarrierFreeManager`.

```dart
void main() {
  BarrierFreeManager.instance.initialize(
    delegate: MyAccessibilityDelegate(),
    keyboardConfig: BFKeyboardConfig(
      upKey: PhysicalKeyboardKey.arrowUp,
      downKey: PhysicalKeyboardKey.arrowDown,
      leftKey: PhysicalKeyboardKey.arrowLeft,
      rightKey: PhysicalKeyboardKey.arrowRight,
      enterKey: PhysicalKeyboardKey.enter,
    ),
  );
  runApp(MyApp());
}
```

### 2. Implement the Delegate
Create a class that implements `BarrierFreeDelegate`. This is where you connect your TTS (Text-to-Speech) service and define focus styles.

```dart
class MyAccessibilityDelegate implements BarrierFreeDelegate {
  // 🗣️ TTS implementation
  @override
  void speak(String text, {bool isFilter = true}) {
    // e.g. using flutter_tts
    print("Voice announcement: $text");
  }

  @override
  void stop() {}

  // 🎨 Customizing focus borders (New in 1.0.7)
  @override
  Color get focusColor => Colors.orangeAccent; // Color for individual items

  @override
  Color get areaFocusColor => Colors.blueAccent.withOpacity(0.5); // Color for areas
}
```

### 3. Wrap Your UI
Define your page structure using the coordinator, groups, and items.

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final FocusNode _headerNode = FocusNode();
  final FocusNode _contentNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BFFocusCoordinator(
      routeName: '/home',
      focusGroups: [
        FocusGroupConfig(focusNode: _headerNode),
        FocusGroupConfig(focusNode: _contentNode),
      ],
      child: Scaffold(
        body: Column(
          children: [
            // Header Area
            BFAreaFocusGroup(
              focusNode: _headerNode,
              ttsMsg: "Top Nav Area",
              child: Row(
                children: [
                   BFFocusItem(
                     ttsMsg: "Home Button",
                     onTap: () => print("Home"),
                     child: Icon(Icons.home),
                   ),
                ],
              ),
            ),
            // Content Area
            BFAreaFocusGroup(
               focusNode: _contentNode,
               ttsMsg: "Main Content",
               child: BFFocusItem(
                 ttsMsg: "Profile",
                 onTap: () => print("Profile"),
                 child: Text("Click Me"),
               ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🛠️ Advanced Customization

### 🌗 Theme-Aware Colors
You can dynamically change focus colors based on your app's theme. When the theme changes, notify the manager to refresh the UI.

```dart
// In your Delegate
@override
Color get focusColor => MyTheme.isDark ? Colors.white : Colors.black;

// After theme toggle
BarrierFreeManager.instance.notifyListeners();
```

### 🎯 Single Child Groups (`isSingleChild`)
If a `BFAreaFocusGroup` only contains one interactive element, set `isSingleChild: true` in your `FocusGroupConfig`. This ensures the focus moves directly into that item when the area is entered.

---

## 🤖 Android Configuration (Critical)

In Android 8.0+ devices, connecting a physical keyboard might show a system-level yellow/green focus highlight. To hide it:

1.  **Edit `styles.xml`**:
    ```xml
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:defaultFocusHighlightEnabled">false</item>
    </style>
    ```
2.  **Declare in `AndroidManifest.xml`**:
    ```xml
    <meta-data
        android:name="io.flutter.embedding.android.NormalTheme"
        android:resource="@style/NormalTheme"
    />
    ```

---

# (한국어) barrier_free_navigation

Flutter용 고도화된 3단계 **배리어 프리(Barrier-Free)** 키보드 내비게이션 패키지입니다.  
*키오스크, 셋톱박스(STB) 리모컨, 접근성이 중요한 모든 인터페이스에 최적화되어 있습니다.*

---

## ✨ 주요 기능

Flutter에서 복잡한 레이아웃을 물리 키패드로 조작하는 것은 매우 까다로울 수 있습니다. 이 패키지는 다음을 제공합니다:
- **계층적 내비게이션**: 개별 아이템을 영역(Area) 단위로 묶어 논리적인 포커스 이동을 가능하게 합니다.
- **내장 TTS 로직**: 포커스가 이동할 때마다 설정해둔 음성 안내가 자동으로 실행됩니다.
- **자유로운 스타일**: 시스템 기본 하이라이트 대신, 서비스 성격에 맞는 테두리 색상과 굵기를 지정할 수 있습니다.
- **키오스크 최적화**: 안드로이드 시스템 포커스 박스를 숨기는 가이드를 포함하여 깔끔한 UI를 보장합니다.

---

## 🏗️ 3단계 아키텍처

| 구성 요소 | 역할 |
| :--- | :--- |
| **`BFFocusCoordinator`** | **화면 레벨**. 하드웨어 키보드 이벤트를 수신하고 화면 전체의 흐름을 제어합니다. |
| **`BFAreaFocusGroup`** | **영역 레벨**. 상단 네비게이션, 본문, 하단 정보 등 큰 덩어리를 의미합니다. (상/하 이동) |
| **`BFFocusItem`** | **아이템 레벨**. 실제 버튼이나 리스트 항목입니다. (좌/우 이동) |

---

## 🚀 빠른 시작

### 1. 매니저 초기화
`main.dart` 등 앱의 시작점에서 `BarrierFreeManager`를 초기화합니다.

```dart
void main() {
  BarrierFreeManager.instance.initialize(
    delegate: MyAccessibilityDelegate(),
    keyboardConfig: BFKeyboardConfig(
      upKey: PhysicalKeyboardKey.arrowUp,
      downKey: PhysicalKeyboardKey.arrowDown,
      leftKey: PhysicalKeyboardKey.arrowLeft,
      rightKey: PhysicalKeyboardKey.arrowRight,
      enterKey: PhysicalKeyboardKey.enter,
    ),
  );
  runApp(MyApp());
}
```

### 2. 델리게이트 구현 (TTS 및 디자인 설정)
`BarrierFreeDelegate`를 상속받아 음성 처리와 테두리 스타일을 정의합니다.

```dart
class MyAccessibilityDelegate implements BarrierFreeDelegate {
  @override
  void speak(String text, {bool isFilter = true}) {
    // TTS를 실행하는 코드 (예: flutter_tts 사용)
    print("음성 안내: $text");
  }

  @override
  void stop() {}

  // 🎨 포커스 테두리 커스텀 (v1.0.7 이상)
  @override
  Color get focusColor => Colors.red; // 개별 버튼 포커스 색상

  @override
  Color get areaFocusColor => Colors.blue.withOpacity(0.3); // 영역 포커스 색상
}
```

---

## 🎯 주요 팁

- **동적 테마 변경**: 앱의 다크모드/라이트모드에 따라 포커스 색상을 바꾸고 싶다면, 델리게이트에서 해당 색상을 반환하게 한 뒤 `BarrierFreeManager.instance.notifyListeners()`를 호출하세요.
- **안드로이드 시스템 테두리**: 안드로이드 8.0 이상에서 나타나는 노란색 테두리를 없애려면 `styles.xml`에서 `defaultFocusHighlightEnabled`를 `false`로 설정해야 합니다. (자세한 설정은 상단 영어 가이드 참조)

---

## 📜 라이선스
MIT License
