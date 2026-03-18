import 'package:flutter/material.dart';
import '../manager/barrier_free_manager.dart';
import '../models/focus_group_config.dart';

/// 화면(Route) 단위로 포커스 그룹 배열을
/// `BarrierFreeManager`에 자동으로 달고 해제(register/unregister)해주는 위젯입니다.
class BFFocusCoordinator extends StatefulWidget {
  final String routeName;
  final Widget child;
  final List<FocusGroupConfig> focusGroups;

  const BFFocusCoordinator({
    super.key,
    required this.routeName,
    required this.focusGroups,
    required this.child,
  });

  @override
  State<BFFocusCoordinator> createState() => _BFFocusCoordinatorState();
}

class _BFFocusCoordinatorState extends State<BFFocusCoordinator> {
  @override
  void initState() {
    super.initState();
    BarrierFreeManager.instance
        .registerFocusGroups(widget.routeName, widget.focusGroups);
  }

  @override
  void didUpdateWidget(BFFocusCoordinator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상태가 변경되거나 화면이 갱신되어 새로 포커스 그룹을 그려야 할 경우
    if (oldWidget.routeName != widget.routeName ||
        oldWidget.focusGroups != widget.focusGroups) {
      BarrierFreeManager.instance
          .registerFocusGroups(widget.routeName, widget.focusGroups);
    }
  }

  @override
  void dispose() {
    BarrierFreeManager.instance.unregisterFocusGroups(widget.routeName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 코디네이터는 라이프사이클 관리용이므로 child를 그대로 반환합니다.
    return widget.child;
  }
}
