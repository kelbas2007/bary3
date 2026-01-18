import 'package:flutter/material.dart';

/// AnimatedListView с поддержкой анимации добавления/удаления элементов
class AnimatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<AnimatedListView<T>> createState() => _AnimatedListViewState<T>();
}

class _AnimatedListViewState<T> extends State<AnimatedListView<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(AnimatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != _items.length) {
      _updateItems();
    }
  }

  void _updateItems() {
    final newItems = widget.items;
    final oldItems = _items;

    // Удаляем элементы, которых больше нет
    for (var i = oldItems.length - 1; i >= 0; i--) {
      if (!newItems.contains(oldItems[i])) {
        _removeItem(i);
      }
    }

    // Добавляем новые элементы
    for (var i = 0; i < newItems.length; i++) {
      if (!oldItems.contains(newItems[i])) {
        _insertItem(i, newItems[i]);
      }
    }

    _items = List.from(newItems);
  }

  void _insertItem(int index, T item) {
    _items.insert(index, item);
    _listKey.currentState?.insertItem(
      index,
      duration: widget.animationDuration,
    );
  }

  void _removeItem(int index) {
    final item = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(context, item, animation),
      duration: widget.animationDuration,
    );
  }

  Widget _buildRemovedItem(
    BuildContext context,
    T item,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: widget.animationCurve),
        ),
      ),
      child: SizeTransition(
        sizeFactor: animation.drive(
          Tween(begin: 1.0, end: 0.0).chain(
            CurveTween(curve: widget.animationCurve),
          ),
        ),
        child: widget.itemBuilder(context, item, _items.indexOf(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: widget.animationCurve),
            ),
          ),
          child: SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.1, 0), end: Offset.zero).chain(
                CurveTween(curve: widget.animationCurve),
              ),
            ),
            child: widget.itemBuilder(context, _items[index], index),
          ),
        );
      },
    );
  }
}
