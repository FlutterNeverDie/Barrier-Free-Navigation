import 'package:flutter/widgets.dart';

class FocusGroupConfig {
  final FocusNode focusNode;
  final bool isSingleChild;

  const FocusGroupConfig({
    required this.focusNode,
    this.isSingleChild = false,
  });
}
