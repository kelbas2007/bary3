import 'package:flutter/widgets.dart';
import 'currency_controller.dart';

class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    super.key,
    required CurrencyController controller,
    required super.child,
  }) : super(notifier: controller);

  static CurrencyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    assert(scope != null, 'No CurrencyScope found in context');
    final controller = scope!.notifier;
    assert(controller != null, 'CurrencyController is null');
    return controller!;
  }
}


