import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Shared Axis переходы для Material 3
class SharedAxisPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;
  final Duration duration;

  SharedAxisPageRoute({
    required this.page,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: transitionType,
      child: child,
    );
  }
}

/// Расширение для удобного использования
extension NavigatorSharedAxis on Navigator {
  Future<T?> pushSharedAxis<T extends Object?>(
    BuildContext context,
    Widget page, {
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      SharedAxisPageRoute<T>(
        page: page,
        transitionType: transitionType,
        duration: duration,
      ),
    );
  }
}
