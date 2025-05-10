import 'package:flutter/widgets.dart';

class TopBounceOnlyScrollPhysics extends BouncingScrollPhysics {
  const TopBounceOnlyScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  TopBounceOnlyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TopBounceOnlyScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // 👆 위로 스크롤 → 바운스 허용
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }

    // 👇 아래로 스크롤 → 바운스 막기
    if (value > position.pixels && position.pixels >= position.maxScrollExtent) {
      return 0.0; // overscroll 막음
    }

    return 0.0;
  }
}
