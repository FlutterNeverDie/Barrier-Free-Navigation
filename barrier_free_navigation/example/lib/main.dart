import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barrier_free_navigation/barrier_free_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyTTSDelegate extends BarrierFreeDelegate {
  @override
  bool get isBarrierFreeModeEnabled => true;

  @override
  bool get isVoiceGuideEnabled => true;

  @override
  void speak(String text, {bool isFilter = true}) {
    // Print instead of actual TTS for the sake of simple example
    debugPrint('🗣️ [TTS SPEAK]: $text');
  }

  @override
  void playClickSound() {
    debugPrint('🔊 [CLICK SOUND]');
  }

  @override
  void onVolumeUp() => debugPrint('Volume Up');

  @override
  void onVolumeDown() => debugPrint('Volume Down');

  @override
  void onCustomKey1() => debugPrint('Custom Key 1');

  @override
  void onCustomKey2() => debugPrint('Custom Key 2');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    BarrierFreeManager.instance.initialize(
      delegate: MyTTSDelegate(),
      config: BFKeyboardConfig(
        groupUpKey: PhysicalKeyboardKey.arrowUp,
        groupDownKey: PhysicalKeyboardKey.arrowDown,
        itemPreviousKey: PhysicalKeyboardKey.arrowLeft,
        itemNextKey: PhysicalKeyboardKey.arrowRight,
        volumeUpKey: PhysicalKeyboardKey.pageUp,
        volumeDownKey: PhysicalKeyboardKey.pageDown,
        customKey1: PhysicalKeyboardKey.f1,
        customKey2: PhysicalKeyboardKey.f2,
        enterKey: PhysicalKeyboardKey.enter,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BarrierFreeManager.instance
          .speak("배리어 프리 데모 화면입니다. 그룹간 이동은 상하 방향키를, 아이템간 이동은 좌우 방향키를 사용하세요.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BarrierFreeExampleScreen(),
    );
  }
}

class BarrierFreeExampleScreen extends StatefulWidget {
  const BarrierFreeExampleScreen({super.key});

  @override
  State<BarrierFreeExampleScreen> createState() =>
      _BarrierFreeExampleScreenState();
}

class _BarrierFreeExampleScreenState extends State<BarrierFreeExampleScreen> {
  final FocusNode _topRowFocus = FocusNode();
  final FocusNode _middleFocus = FocusNode();

  @override
  void dispose() {
    _topRowFocus.dispose();
    _middleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BFFocusCoordinator(
      routeName: '/example',
      focusGroups: [
        FocusGroupConfig(focusNode: _topRowFocus, isSingleChild: false),
        FocusGroupConfig(focusNode: _middleFocus, isSingleChild: true),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Barrier-Free Example'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 50),

            // Group 1: A row of buttons (isSingleChild: false)
            BFAreaFocusGroup(
              focusNode: _topRowFocus,
              ttsMsg: '상단 버튼 그룹입니다.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BFFocusItem(
                    ttsMsg: '첫 번째 버튼',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('버튼 1 눌림')),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.blue.withAlpha(128), // withOpacity(0.5)
                      child: const Text('버튼 1'),
                    ),
                  ),
                  BFFocusItem(
                    ttsMsg: '두 번째 버튼',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('버튼 2 눌림')),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.green.withAlpha(128), // withOpacity(0.5)
                      child: const Text('버튼 2'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Group 2: A single large target (isSingleChild: true)
            BFAreaFocusGroup(
              focusNode: _middleFocus,
              ttsMsg: '',
              child: BFFocusItem(
                ttsMsg: '하단 확인 버튼입니다.',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('확인 완료')),
                ),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(40),
                  color: Colors.redAccent.withAlpha(128), // withOpacity(0.5)
                  child: const Center(
                      child: Text('확인', style: TextStyle(fontSize: 24))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
