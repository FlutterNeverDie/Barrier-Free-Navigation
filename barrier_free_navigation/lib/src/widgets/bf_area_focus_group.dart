import 'package:flutter/material.dart';
import '../manager/barrier_free_manager.dart';

/// 여러 개의 포커스 아이템을 하나로 묶어주는 영역(그룹) 단위 위젯입니다.
/// A widget that groups multiple focus items into a single area unit.
class BFAreaFocusGroup extends StatefulWidget {
  /// 그룹 내부에 렌더링될 하위 위젯
  /// The child widget to be rendered inside the group
  final Widget child;

  /// 본 영역(그룹)이 포커스를 얻었는지 판별하기 위한 FocusNode
  /// FocusNode to determine if this area (group) has gained focus
  final FocusNode focusNode;

  /// 이 그룹에 포커스가 도착했을 때 TTS로 읽어줄 메시지
  /// Message to be read by TTS when focus reaches this group
  final String? ttsMsg;

  /// 그룹 내에 포커스를 받을 수 있는 자식이 단 하나뿐인지 여부
  /// (true면 그룹이 포커스를 얻자마자 그 단일 자식에게 즉시 포커스를 넘깁니다.)
  /// Whether there is only a single focusable child within the group
  /// (If true, passes focus immediately to the single child upon gaining area focus.)
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
            color: BarrierFreeManager.instance.areaFocusColor,
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
