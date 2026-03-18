import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/barrier_free_delegate.dart';
import '../models/bf_keyboard_config.dart';
import '../models/focus_group_config.dart';

class BarrierFreeManager {
  static final BarrierFreeManager instance = BarrierFreeManager._();
  BarrierFreeManager._();

  BarrierFreeDelegate? _delegate;
  BFKeyboardConfig? _config;

  final List<String> _focusKeyStack = [];
  final Map<String, List<FocusGroupConfig>> _focusGroupConfigMap = {};
  int _currentGroupIndex = 0;
  bool _isInitialized = false;

  void initialize({
    required BarrierFreeDelegate delegate,
    required BFKeyboardConfig config,
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
  }

  /// 키보드 설정 정보
  BFKeyboardConfig? get config => _config;

  /// 배리어프리 관련 Delegate 기능들
  void speak(String text, {bool isFilter = false}) {
    if (_delegate?.isVoiceGuideEnabled == true) {
      _delegate?.speak(text, isFilter: isFilter);
    }
  }

  void playClickSound() {
    _delegate?.playClickSound();
  }

  bool get isBarrierFreeModeEnabled =>
      _delegate?.isBarrierFreeModeEnabled ?? false;

  /// 포커스 영역(그룹) 등록을 위한 스택 관리
  void registerFocusGroups(String routeName, List<FocusGroupConfig> configs) {
    if (configs.isEmpty) return;
    _focusGroupConfigMap[routeName] = configs;

    // Stack의 최상단으로 관리하기 위해 기존에 있으면 제거
    if (_focusKeyStack.contains(routeName)) {
      _focusKeyStack.remove(routeName);
    }
    _focusKeyStack.add(routeName);
    _currentGroupIndex = 0;
  }

  void unregisterFocusGroups(String routeName) {
    _focusGroupConfigMap.remove(routeName);
    _focusKeyStack.remove(routeName);
    _currentGroupIndex = 0;
  }

  /// Keyboard Handler 전역 이벤트
  bool handleKeyEvent(KeyEvent event) {
    if (!_isInitialized || _config == null) return false;

    if (event is! KeyDownEvent) return true;

    final key = event.physicalKey;

    // 1. 앱 전역의 커스텀 단축키가 먼저 처리되는지 확인
    if (_config!.onCustomAppKeyEvent != null) {
      final isHandled = _config!.onCustomAppKeyEvent!(key);
      if (isHandled) return true;
    }

    // 2. 방향키 이동 처리 (그룹 및 아이템)
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

    // 3. 엔터 키 등은 native flutter tap이 핸들링하도록 위임
    return false;
  }

  void _moveToWidget({required bool isRight}) {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) return;

    if (isRight) {
      currentFocus.nextFocus();
    } else {
      currentFocus.previousFocus();
    }
  }

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

    final currentConfig = configs[_currentGroupIndex];
    currentConfig.focusNode.requestFocus();

    // 단일 자식 위젯이면 자동으로 그 하위 위젯 탭으로 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentConfig.isSingleChild) {
        _moveToFirstFocusableInGroup();
      }
    });
  }

  List<FocusGroupConfig>? get _currentFocusGroupConfigs {
    if (_focusKeyStack.isEmpty) return null;
    final activeKey = _focusKeyStack.last;
    return _focusGroupConfigMap[activeKey];
  }

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
        }
        return;
      }
    }
  }

  bool _isDescendantOf(FocusNode currentFocus, FocusNode groupNode) {
    FocusNode? parent = currentFocus.parent;
    while (parent != null) {
      if (parent == groupNode) return true;
      parent = parent.parent;
    }
    return false;
  }

  void _moveToFirstFocusableInGroup() {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus != null) {
      final scope = currentFocus.enclosingScope;
      scope?.nextFocus();
    }
  }
}
