import 'package:flutter/widgets.dart';

/// 포커스 영역(그룹)의 설정 모델 클래스
/// Configuration model class for a focus area (group)
class FocusGroupConfig {
  /// 해당 그룹을 관리할 FocusNode
  /// FocusNode to manage this group
  final FocusNode focusNode;

  /// 단일 자식 요소만 갖는 그룹인지 여부
  /// (true일 경우 그룹 진입 시 하위 자식에게 즉시 포커스를 전달함)
  /// Whether the group has only a single child element
  /// (If true, focus is immediately passed to the child when entering the group)
  final bool isSingleChild;

  const FocusGroupConfig({
    required this.focusNode,
    this.isSingleChild = false,
  });
}
