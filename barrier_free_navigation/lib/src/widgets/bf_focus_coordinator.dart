import 'package:flutter/material.dart';
import '../manager/barrier_free_manager.dart';
import '../models/focus_group_config.dart';

/// 화면(Route) 단위로 포커스 그룹 배열을
/// `BarrierFreeManager`에 자동으로 달고 해제(register/unregister)해주는 위젯입니다.
/// A widget that automatically registers and unregisters an array of focus groups
/// to the `BarrierFreeManager` on a per-screen (Route) basis.
class BFFocusCoordinator extends StatefulWidget {
  /// 현재 라우트(화면)의 고유 이름
  /// Unique name of the current route (screen)
  final String routeName;

  /// 화면에 표시될 자식 위젯
  /// The child widget to be displayed on the screen
  final Widget child;

  /// 이 화면에서 관리할 포커스 그룹 설정 목록
  /// List of focus group configurations to be managed in this screen
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
