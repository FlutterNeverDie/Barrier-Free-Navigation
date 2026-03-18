import 'package:flutter/material.dart';
import '../manager/barrier_free_manager.dart';

class BFAreaFocusGroup extends StatefulWidget {
  /// 자식 위젯
  final Widget child;

  /// 영역 포커스용 FocusNode
  final FocusNode focusNode;

  /// TTS로 재생할 메시지
  final String? ttsMsg;

  /// 단일 자식 여부
  final bool isSingleChild;

  const BFAreaFocusGroup({
    super.key,
    required this.child,
    required this.focusNode,
    this.ttsMsg,
    this.isSingleChild = false,
  });

  @override
  State<BFAreaFocusGroup> createState() => _BFAreaFocusGroupState();
}

class _BFAreaFocusGroupState extends State<BFAreaFocusGroup> {
  bool _hasAreaFocus = false;
  bool _hasChildFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onAreaFocusChange);
    FocusManager.instance.addListener(_onGlobalFocusChange);
    _updateFocusStates();
  }

  void _onGlobalFocusChange() {
    _updateFocusStates();
  }

  void _updateFocusStates() {
    if (!mounted) return;

    final currentFocus = FocusManager.instance.primaryFocus;
    final areaFocusNow = widget.focusNode.hasFocus;
    final isChildFocused = currentFocus != null &&
        _isDescendantOf(currentFocus, widget.focusNode) &&
        currentFocus != widget.focusNode;

    if (_hasAreaFocus != areaFocusNow || _hasChildFocus != isChildFocused) {
      setState(() {
        _hasAreaFocus = areaFocusNow;
        _hasChildFocus = isChildFocused;
      });
    }
  }

  void _onAreaFocusChange() {
    if (!mounted) return;

    _updateFocusStates();

    // 영역에 처음 포커스가 들어왔고, 하위 노드 포커스가 아니면 TTS 재생 (단일 아닐때만)
    if (_hasAreaFocus && !_hasChildFocus && !widget.isSingleChild) {
      _speakAreaMessage();
    }
  }

  bool _isDescendantOf(FocusNode currentFocus, FocusNode areaNode) {
    FocusNode? parent = currentFocus.parent;
    while (parent != null) {
      if (parent == areaNode) return true;
      parent = parent.parent;
    }
    return false;
  }

  void _speakAreaMessage() {
    if (widget.ttsMsg == null) return;
    BarrierFreeManager.instance.speak(widget.ttsMsg!);
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Focus(
        focusNode: widget.focusNode,
        skipTraversal: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            if (_hasAreaFocus && !_hasChildFocus) _buildAreaFocusOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaFocusOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF2196F3),
              width: 3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BFAreaFocusGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onAreaFocusChange);
      widget.focusNode.addListener(_onAreaFocusChange);
      _updateFocusStates();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onAreaFocusChange);
    FocusManager.instance.removeListener(_onGlobalFocusChange);
    super.dispose();
  }
}
