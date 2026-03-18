import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../manager/barrier_free_manager.dart';

class BFFocusItem extends StatefulWidget {
  /// 자식 위젯
  final Widget child;

  /// TTS로 재생할 메시지
  final String? ttsMsg;

  /// 탭 또는 엔터 키 이벤트 시 실행할 콜백
  final VoidCallback? onTap;

  /// TTS 필터링 여부
  final bool isFilterTts;

  /// 자동 포커스 여부
  final bool autoFocus;

  /// 잉크 효과의 테두리 반경
  final double inkBorderRadius;

  /// 포커스 상태 변화 콜백
  final Function(bool)? onFocusChange;

  final Decoration decoration;
  final double? height;

  const BFFocusItem({
    super.key,
    required this.child,
    this.ttsMsg,
    this.decoration = const BoxDecoration(),
    this.onTap,
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
            border: Border.all(color: Colors.blue, width: 2),
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
