# barrier_free_navigation

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) 
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Pub Version](https://img.shields.io/pub/v/barrier_free_navigation?label=pub.dev&color=blue)

Flutter를 위한 고도화된 3단계 **배리어 프리(Barrier-Free)** 키보드 내비게이션 패키지입니다.  
키오스크, 셋톱박스(STB) 리모컨, 시각 장애인을 위한 접근성 인터페이스 등 물리적인 키 입력이 필요한 모든 환경에 최적화되어 있습니다.

---

## 🇰🇷 한국어 사용 가이드 (Detailed Korean Guide)

이 패키지는 단순히 포커스를 이동시키는 것이 아니라, **화면의 논리적 구역(Area)**과 **개별 항목(Item)**을 계층적으로 관리하여 사용자에게 일관된 내비게이션 경험을 제공합니다.

### 🌟 주요 특징
- **계층적 내비게이션 (3-Tier)**: 화면(Route) -> 영역(Group) -> 아이템(Item) 단위로 포커스를 관리합니다.
- **포커스 유지 최적화 (v1.1.1+)**: 화면이 리빌드되어도 사용자가 현재 보고 있던 포커스 위치를 기억하고 유지합니다.
- **통합 TTS(음성 안내) 지원**: 포커스가 이동할 때마다 별도의 추가 코드 없이 설정된 안내 문구가 자동으로 낭독됩니다.
- **고도화된 커스터마이징**: 포커스 테두리 색상, 굵기, 키보드 매핑 등을 자유롭게 설정할 수 있습니다.
- **키오스크 완벽 대응**: 안드로이드 시스템 특유의 불필요한 포커스 하이라이트를 제거하는 가이드를 포함합니다.

---

### 🏗️ 3단계 아키텍처 이해하기

| 구성 요소 | 레벨 | 역할 |
| :--- | :--- | :--- |
| **`BFFocusCoordinator`** | **화면(Page)** | 물리 키보드 이벤트를 전역에서 수신하고, 해당 화면의 포커스 그룹들을 총괄 관리합니다. |
| **`BFAreaFocusGroup`** | **구역(Area)** | 여러 아이템을 하나로 묶는 논리적 단위입니다 (예: 메뉴바, 본문, 장바구니). **상/하 키**로 구역 간 이동이 가능합니다. |
| **`BFFocusItem`** | **아이템(Item)** | 실제 클릭이 가능한 버튼이나 리스트 항목입니다. **좌/우 키**로 구역 내에서 이동합니다. |

---

### 🚀 시작하기

#### 1. 매니저 초기화 (`main.dart`)
앱의 진입점에서 매니저를 초기화하고 키보드 맵핑을 설정합니다.

```dart
void main() {
  // 1. 매니저 초기화
  BarrierFreeManager.instance.initialize(
    delegate: MyAccessibilityDelegate(), // 2번 단계에서 구현
    config: BFKeyboardConfig(
      groupUpKey: PhysicalKeyboardKey.arrowUp,    // 구역 간 이전 이동 (위)
      groupDownKey: PhysicalKeyboardKey.arrowDown, // 구역 간 다음 이동 (아래)
      itemPreviousKey: PhysicalKeyboardKey.arrowLeft, // 아이템 간 이전 이동 (왼쪽)
      itemNextKey: PhysicalKeyboardKey.arrowRight,    // 아이템 간 다음 이동 (오른쪽)
      // 기타 커스텀 키 설정 가능 (volumeUp, volumeDown 등)
    ),
  );

  runApp(const MyApp());
}
```

#### 2. 델리게이트 구현 (`BarrierFreeDelegate`)
음성 안내(TTS) 로직과 디자인 스타일을 정의합니다.

```dart
class MyAccessibilityDelegate implements BarrierFreeDelegate {
  // 🗣️ TTS 엔진 연결 (예: flutter_tts 사용)
  @override
  void speak(String text, {bool isFilter = false}) {
    print("TTS 낭독: $text");
    // FlutterTts().speak(text);
  }

  @override
  void stop() { /* TTS 중지 로직 */ }

  // 🎨 시각적 커스터마이징
  @override
  Color get focusColor => const Color(0xFF2196F3); // 개별 아이템 포커스 색상
  
  @override
  Color get areaFocusColor => const Color(0x332196F3); // 구역 포커스 색상 (반투명 권장)

  @override
  bool get isVoiceGuideEnabled => true; // 음성 안내 활성화 여부
  
  @override
  bool get isBarrierFreeModeEnabled => true; // 배리어프리 모드 전체 활성화 여부

  @override
  void onVolumeUp() { /* 볼륨 조절 로직 */ }
  
  @override
  void onVolumeDown() { /* 볼륨 조절 로직 */ }
}
```

#### 3. 화면 구현 (UI 적용)
`BFFocusCoordinator`로 화면을 감싸고, 구역과 아이템을 배치합니다.

```dart
class MyOrderPage extends StatefulWidget {
  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  // 각 구역을 위한 FocusNode 생성
  final FocusNode _menuGroupNode = FocusNode();
  final FocusNode _cartGroupNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BFFocusCoordinator(
      routeName: 'order_page', // 화면 식별자
      focusGroups: [
        FocusGroupConfig(focusNode: _menuGroupNode),
        FocusGroupConfig(focusNode: _cartGroupNode),
      ],
      child: Scaffold(
        body: Column(
          children: [
            // 🍔 메뉴 구역 (상/하 키로 진입)
            BFAreaFocusGroup(
              focusNode: _menuGroupNode,
              ttsMsg: "메뉴 선택 영역입니다.",
              child: Row(
                children: [
                  BFFocusItem(
                    ttsMsg: "불고기 버거, 5,500원",
                    onTap: () => _addToCart("Bulgogi"),
                    child: MyMenuItem(name: "불고기 버거"),
                  ),
                  BFFocusItem(
                    ttsMsg: "치즈 버거, 5,000원",
                    onTap: () => _addToCart("Cheese"),
                    child: MyMenuItem(name: "치즈 버거"),
                  ),
                ],
              ),
            ),
            
            // 🛒 장바구니 구역
            BFAreaFocusGroup(
              focusNode: _cartGroupNode,
              ttsMsg: "장바구니 영역입니다.",
              child: BFFocusItem(
                ttsMsg: "결제하기 버튼",
                onTap: () => _goPay(),
                child: MyPayButton(),
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

### 🤖 안드로이드 시스템 설정 (중요)

안드로이드 8.0 이상 기기에서 물리 키보드를 연결하면 시스템이 강제로 노란색/초록색 포커스 하이라이트를 그립니다. 이를 제거하고 패키지의 커스텀 포커스만 보이게 하려면 다음 설정을 반드시 수행해야 합니다.

**1. `android/app/src/main/res/values/styles.xml` 수정**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- 기본 테마 수정 -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- 시스템 포커스 하이라이트 비활성화 -->
        <item name="android:defaultFocusHighlightEnabled">false</item>
    </style>
</resources>
```

**2. `AndroidManifest.xml`에서 해당 스타일 적용**
```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/NormalTheme"
    ...>
```

---

### 💡 팁과 노하우

- **단일 자식 구역 (`isSingleChild`)**: 
  장바구니 버튼처럼 구역 내에 아이템이 하나뿐이라면 `FocusGroupConfig(focusNode: node, isSingleChild: true)`를 설정하세요. 구역에 진입하자마자 자동으로 버튼에 포커스가 잡혀 훨씬 편리합니다.
  
- **포커스 인덱스 보존 (v1.1.1 신기능)**: 
  화면 안의 데이터가 바뀌어 리빌드(setState)가 발생해도, 사용자가 보고 있던 포커스 번호가 0번으로 초기화되지 않고 그대로 유지됩니다.

- **볼륨 및 커스텀 키**: 
  `BFKeyboardConfig`에 `volumeUpKey`, `customKey1` 등을 매핑하면 하드웨어 전용 버튼 이벤트를 쉽게 처리할 수 있습니다.

---

## 🌎 README (English Summary)

This package provides a robust **3-tier navigation system** for hardware keyboard interaction in Flutter.

### Tier 1: Page Level (`BFFocusCoordinator`)
Handles global key events and manages screen-specific focus maps.

### Tier 2: Area Level (`BFAreaFocusGroup`)
Groups items into logical sections. Users navigate between areas using **Up/Down** keys.

### Tier 3: Item Level (`BFFocusItem`)
Individual focusable elements (buttons, etc.). Users navigate within an area using **Left/Right** keys.

### Key Optimization (v1.1.1)
The focus index is now preserved during widget rebuilds if the route remains active, preventing the focus from "jumping" back to the first item unexpectedly.

---

## 📜 License
MIT License.

## ✍️ Author
**FlutterNeverDie** (sanghoon)  
Feel free to open issues or contribute!
