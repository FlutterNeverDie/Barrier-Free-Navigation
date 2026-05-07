import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../manager/barrier_free_manager.dart';

/// 개별적으로 포커스를 받을 수 있는 최소 단위의 상호작용 위젯입니다.
/// 버튼, 리스트 아이템 등 실제 선택 가능한 요소를 감싸는 데 사용됩니다.
/// A minimum interactive widget unit that can individually receive focus.
/// Used to wrap actual selectable elements like buttons or list items.
class BFFocusItem extends StatefulWidget {
  /// 렌더링될 실제 UI 자식 위젯
  /// The actual UI child widget to be rendered
  final Widget child;

  /// 해당 아이템이 포커스를 받았을 때 TTS로 읽어줄 메시지
  /// Message to be read by TTS when this item receives focus
  final String? ttsMsg;

  /// 사용자가 확인(Enter) 버튼 등 특정 동작 키를 눌렀을 때 실행될 콜백
  /// Callback executed when the user presses an action key like Confirm (Enter)
  final VoidCallback? onTap;

  /// 사용자가 아이템을 길게 눌렀을 때 실행될 콜백
  /// Callback executed when the user long presses the item
  final VoidCallback? onLongPress;

  /// 같은 TTS 메시지를 반복 중복해서 읽지 않도록 필터링할지 여부
  /// Whether to filter TTS so that the exact same message is not read repeatedly
  final bool isFilterTts;

  /// 화면 또는 그룹 진입 시 이 아이템에 자동으로 포커스를 줄지 여부
  /// Whether to automatically focus this item when entering the screen or group
  final bool autoFocus;

  /// 탭할 때 나타나는 기본 물결(Ink) 효과의 모서리 반경
  /// Border radius of the default Ink ripple effect shown on tap
  final double inkBorderRadius;

  /// 포커스 획득/상실 상태가 변경될 때 호출되는 콜백 (true: 포커스 획득, false: 상실)
  /// Callback invoked when focus state changes (true: gained focus, false: lost focus)
  final Function(bool)? onFocusChange;

  /// 아이템 배경 장식 (BoxDecoration 등)
  /// Background decoration for the item (e.g., BoxDecoration)
  final Decoration decoration;
  
  /// 아이템의 고정 높이
  /// Fixed height of the item
  final double? height;

  const BFFocusItem({
    super.key,
    required this.child,
    this.ttsMsg,
    this.decoration = const BoxDecoration(),
    this.onTap,
    this.onLongPress,
    this.isFilterTts = false,
    this.autoFocus = false,
    this.inkBorderRadius = 16.0,
    this.height,
    this.onFocusChange,
  });

  @override
  State<BFFocusItem> createState() => _BFFocusItemState();
}

class _BFFocusItemState extends State<BFFocusItem> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _handleAutoFocus();
  }

  void _handleAutoFocus() {
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && BarrierFreeManager.instance.isBarrierFreeModeEnabled) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _speakMessage();
      if (widget.onFocusChange != null) {
        widget.onFocusChange!(true);
      }
    } else {
      if (widget.onFocusChange != null) {
        widget.onFocusChange!(false);
      }
    }
  }

  void _speakMessage() {
    if (widget.ttsMsg == null) return;
    BarrierFreeManager.instance
        .speak(widget.ttsMsg!, isFilter: widget.isFilterTts);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && _focusNode.hasFocus) {
      final config = BarrierFreeManager.instance.config;
      if (config != null && event.physicalKey == config.enterKey) {
        _handleTap();
        return KeyEventResult.handled;
      }

      // 혹시라도 LogicalKeyboardKey.enter에도 대응
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleTap();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleTap() {
    if (widget.onTap != null) {
      BarrierFreeManager.instance.playClickSound();
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      // 길게 누르기 시에도 클릭 사운드를 재생할지 여부는 정책에 따라 다를 수 있으나,
      // 사용자 경험을 위해 일단 추가합니다. (필요 시 제거 가능)
      BarrierFreeManager.instance.playClickSound();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return ExcludeFocus(
            child: SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: widget.decoration,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(widget.inkBorderRadius),
                        onTap: _handleTap,
                        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
                        child: widget.child,
                      ),
                    ),
                  ),
                  if (hasFocus) _buildFocusOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFocusOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
                color: BarrierFreeManager.instance.focusColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}
