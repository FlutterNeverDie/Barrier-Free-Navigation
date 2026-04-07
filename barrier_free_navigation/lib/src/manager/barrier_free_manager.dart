import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/barrier_free_delegate.dart';
import '../models/bf_keyboard_config.dart';
import '../models/focus_group_config.dart';

/// 배리어프리 네비게이션을 중앙 제어하는 싱글톤 매니저
/// A singleton manager that centrally controls barrier-free navigation
class BarrierFreeManager with ChangeNotifier {
  static final BarrierFreeManager instance = BarrierFreeManager._();
  BarrierFreeManager._();

  static const MethodChannel _channel =
      MethodChannel('barrier_free_navigation/init');

  BarrierFreeDelegate? _delegate;
  BFKeyboardConfig? _config;

  final List<String> _focusKeyStack = [];
  final Map<String, List<FocusGroupConfig>> _focusGroupConfigMap = {};
  int _currentGroupIndex = 0;
  bool _isInitialized = false;

  /// 매니저 초기화. 구성 요소 및 콜백을 등록합니다.
  /// Initializes the manager. Registers configurations and callbacks.
  void initialize({
    required BarrierFreeDelegate delegate,
    required BFKeyboardConfig config,
    bool requestInitialFocus = true,
  }) {
    if (_isInitialized) return;
    _delegate = delegate;
    _config = config;

    FocusManager.instance.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncGroupIndexWithCurrentFocus();
      });
    });

    _isInitialized = true;
    
    // 플러터 프레임워크 레벨에서 물리 키보드 감지 시 그리는 포커스 하이라이트 인디케이터를 비활성화합니다.
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;

    // 안드로이드 하드웨어 키보드 초기 인식을 위한 엔터키 킥스타트 시뮬레이션
    if (requestInitialFocus && Platform.isAndroid) {
      _requestKeyboardFocus();
    }

    notifyListeners();
  }

  /// 안드로이드 시스템에 키보드 포커스 및 초기 상호작용(엔터키)을 강제로 요청합니다.
  Future<void> _requestKeyboardFocus() async {
    try {
      final result = await _channel.invokeMethod('requestKeyboardFocus');
      if (_delegate?.isDebugEnabled == true) {
        debugPrint('[BarrierFreeManager] $result');
      }
    } on PlatformException catch (e) {
      debugPrint('[BarrierFreeManager] Failed to request focus: ${e.message}');
    }
  }

  /// 등록된 키보드 설정 정보
  /// Registered keyboard configuration
  BFKeyboardConfig? get config => _config;

  /// 현재 활성화된(스택 가장 위에 있는) 라우트 이름을 반환합니다.
  /// 네비게이션 스택이 비어있으면 null을 반환합니다.
  String? get currentRouteName =>
      _focusKeyStack.isNotEmpty ? _focusKeyStack.last : null;

  /// 현재 선택된 포커스 그룹의 인덱스를 반환합니다.
  /// Returns the current group index.
  int get currentGroupIndex => _currentGroupIndex;

  /// 매니저의 초기화 여부를 반환합니다.
  /// Returns whether the manager is initialized.
  bool get isInitialized => _isInitialized;

  /// 음성 안내 기능의 활성화 여부를 반환합니다.
  /// Returns whether the voice guide (TTS) feature is enabled.
  bool get isVoiceGuideEnabled => _delegate?.isVoiceGuideEnabled ?? false;

  /// 현재 화면의 포커스 그룹 설정 목록을 반환합니다.
  /// Returns the current focus group configurations.
  List<FocusGroupConfig>? get currentFocusGroups => _currentFocusGroupConfigs;

  /// 현재 관리되고 있는 라우트 네임 스택 (읽기 전용)
  /// Current managed route name stack (read-only)
  List<String> get focusKeyStack => List.unmodifiable(_focusKeyStack);

  /// TTS를 통한 음성 출력 요청
  /// Request voice output via TTS
  void speak(String text, {bool isFilter = false}) {
    if (_delegate?.isVoiceGuideEnabled == true) {
      _delegate?.speak(text, isFilter: isFilter);
    }
  }

  /// 클릭 효과음 재생 요청
  /// Request to play click sound effect
  void playClickSound() {
    _delegate?.playClickSound();
  }

  /// 배리어프리 모드 활성화 여부
  /// Whether barrier-free mode is enabled
  bool get isBarrierFreeModeEnabled =>
      _delegate?.isBarrierFreeModeEnabled ?? false;

  /// 개별 포커스 아이템의 테두리 색상
  /// Border color of individual focus items
  Color get focusColor => _delegate?.focusColor ?? const Color(0xFF2196F3);

  /// 영역(그룹) 포커스의 테두리 색상
  /// Border color for area (group) focus
  Color get areaFocusColor =>
      _delegate?.areaFocusColor ?? const Color(0xFF2196F3);

  /// 특정 라우트(화면)에 대한 포커스 그룹 목록을 등록 및 스택에 푸시
  /// Register focus group list for a specific route (screen) and push to the stack
  void registerFocusGroups(String routeName, List<FocusGroupConfig> configs) {
    if (configs.isEmpty) return;

    // 이미 등록되어 있는지 확인 (스택 포함 여부)
    final bool isAlreadyInStack = _focusKeyStack.contains(routeName);

    if (isAlreadyInStack) {
      // 1. 이미 등록된 경우 -> 설정만 갱신 (순서 유지, 인덱스 유지)
      _focusGroupConfigMap[routeName] = configs;
      
      if (_delegate?.isDebugEnabled == true) {
        debugPrint(
            '[BarrierFreeManager] Route already registered, updating configs only: $routeName');
      }
      
      // 현재 활성화된 화면인 경우에만 알림
      if (_focusKeyStack.isNotEmpty && _focusKeyStack.last == routeName) {
        notifyListeners();
      }
      return;
    }

    // 2. 신규 등록인 경우 -> 스택에 추가하고 인덱스 초기화
    _focusKeyStack.add(routeName);
    _focusGroupConfigMap[routeName] = configs;
    _currentGroupIndex = 0;

    if (_delegate?.isDebugEnabled == true) {
      debugPrint('[BarrierFreeManager] New route registered: $routeName');
    }

    notifyListeners();
  }

  /// 특정 라우트(화면)에 대한 포커스 그룹 목록을 해제
  /// Unregister focus group list for a specific route
  void unregisterFocusGroups(String routeName) {
    _focusGroupConfigMap.remove(routeName);
    _focusKeyStack.remove(routeName);
    _currentGroupIndex = 0;

    if (_delegate?.isDebugEnabled == true) {
      debugPrint('[BarrierFreeManager] Route unregistered: $routeName');
    }

    notifyListeners();
  }

  /// 전역 키보드 이벤트 핸들러
  /// Global keyboard event handler
  bool handleKeyEvent(KeyEvent event) {
    if (!_isInitialized || _config == null) return false;

    if (event is! KeyDownEvent) return true;

    final key = event.physicalKey;

    // 1. 앱 전역의 커스텀 단축키가 먼저 처리되는지 확인
    // 1. Check if the app-wide custom shortcut is handled first
    if (_config!.onCustomAppKeyEvent != null) {
      final isHandled = _config!.onCustomAppKeyEvent!(key);
      if (isHandled) return true;
    }

    // 2. 방향키 이동 및 기타 커스텀 키 동작 처리
    // 2. Handle directional key movements and other custom key actions
    if (key == _config!.groupUpKey) {
      _moveToGroup(isUpward: true);
      return true;
    } else if (key == _config!.groupDownKey) {
      _moveToGroup(isUpward: false);
      return true;
    } else if (key == _config!.itemPreviousKey) {
      _moveToWidget(isRight: false);
      return true;
    } else if (key == _config!.itemNextKey) {
      _moveToWidget(isRight: true);
      return true;
    } else if (key == _config!.volumeUpKey) {
      _delegate?.onVolumeUp();
      return true;
    } else if (key == _config!.volumeDownKey) {
      _delegate?.onVolumeDown();
      return true;
    } else if (key == _config!.customKey1) {
      _delegate?.onCustomKey1();
      return true;
    } else if (key == _config!.customKey2) {
      _delegate?.onCustomKey2();
      return true;
    }

    // 3. 엔터 키 등은 Flutter 네이티브 동작에 위임
    // 3. Delegate enter key, etc., to Flutter's native behaviors
    return false;
  }

  /// 동일 그룹 내 좌/우(이전/다음) 위젯으로 포커스 이동
  /// Move focus to left/right (previous/next) widget within the same group
  void _moveToWidget({required bool isRight}) {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) return;

    if (isRight) {
      currentFocus.nextFocus();
    } else {
      currentFocus.previousFocus();
    }
  }

  /// 상/하 구역(그룹)으로 포커스 크게 점프
  /// Jump focus widely to the UP/DOWN zone (group)
  void _moveToGroup({required bool isUpward}) {
    final configs = _currentFocusGroupConfigs;
    if (configs == null || configs.isEmpty) return;

    final lastIndex = configs.length - 1;

    if (isUpward) {
      _currentGroupIndex =
          (_currentGroupIndex > 0) ? _currentGroupIndex - 1 : lastIndex;
    } else {
      _currentGroupIndex = (_currentGroupIndex + 1) % configs.length;
    }
    notifyListeners();

    final currentConfig = configs[_currentGroupIndex];
    currentConfig.focusNode.requestFocus();

    // 단일 자식 위젯이면 자동으로 그 하위 위젯 탭으로 포커스 진입
    // If it's a single-child widget, automatically focus on its descendant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentConfig.isSingleChild) {
        _moveToFirstFocusableInGroup();
      }
    });
  }

  /// 현재 최상위 화면(Route)의 그룹 설정값 목록 조회
  /// Get the group configurations of the current top-most screen (Route)
  List<FocusGroupConfig>? get _currentFocusGroupConfigs {
    if (_focusKeyStack.isEmpty) return null;
    final activeKey = _focusKeyStack.last;
    return _focusGroupConfigMap[activeKey];
  }

  /// 사용자가 마우스나 터치 등으로 포커스를 변경했을 때, 현재 선택된 포커스의 부모 그룹 인덱스를 동기화
  /// Sync the parent group index of the currently selected focus when the user changes focus via mouse or touch
  void _syncGroupIndexWithCurrentFocus() {
    final currentFocus = FocusManager.instance.primaryFocus;
    final configs = _currentFocusGroupConfigs;
    if (currentFocus == null || configs == null) return;

    for (int i = 0; i < configs.length; i++) {
      final groupNode = configs[i].focusNode;
      if (currentFocus == groupNode ||
          _isDescendantOf(currentFocus, groupNode)) {
        if (_currentGroupIndex != i) {
          _currentGroupIndex = i;
          notifyListeners();
        }
        return;
      }
    }
  }

  /// currentFocus가 groupNode의 하위 위젯인지 확인
  /// Check if currentFocus is a descendant of groupNode
  bool _isDescendantOf(FocusNode currentFocus, FocusNode groupNode) {
    FocusNode? parent = currentFocus.parent;
    while (parent != null) {
      if (parent == groupNode) return true;
      parent = parent.parent;
    }
    return false;
  }

  /// 그룹 내의 첫 번째 활성화 요소로 즉시 포커스 이동 (단일 자식 그룹 등에서 사용)
  /// Move focus immediately to the first focusable element in the group (used for single-child groups)
  void _moveToFirstFocusableInGroup() {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus != null) {
      final scope = currentFocus.enclosingScope;
      scope?.nextFocus();
    }
  }
}
