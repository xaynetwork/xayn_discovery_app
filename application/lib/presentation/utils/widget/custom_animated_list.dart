import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(
    BuildContext, int, Animation<double>, T data);

class CustomAnimatedList<T> extends StatefulWidget {
  final ItemBuilder<T> itemBuilder;
  final List<T> items;
  final bool Function(T a, T b) areItemsTheSame;

  CustomAnimatedList({
    Key? key,
    required this.itemBuilder,
    required Iterable items,
    required this.areItemsTheSame,
  })  : items = List<T>.from(items, growable: false),
        super(key: key);

  @override
  _CustomAnimatedListState<T> createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState<T> extends State<CustomAnimatedList<T>> {
  late GlobalKey<AnimatedListState> _listKey;
  late ItemBuilder<T> _itemBuilder;

  @override
  void initState() {
    _listKey = GlobalKey<AnimatedListState>();
    _itemBuilder = (context, index, animation, data) => _SizeTransition(
          sizeFactor: animation,
          child: widget.itemBuilder(
            context,
            index,
            animation,
            data,
          ),
        );
    super.initState();
  }

  @override
  void didUpdateWidget(CustomAnimatedList<T> oldWidget) {
    _calcDiff(oldWidget.items, widget.items);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => AnimatedList(
        key: _listKey,
        initialItemCount: widget.items.length,
        itemBuilder: (context, index, animation) => _itemBuilder(
          context,
          index,
          animation,
          widget.items[index],
        ),
      );

  void _calcDiff(List<T> outgoing, List<T> incoming) {
    final l1 = outgoing.length, l2 = incoming.length;
    final delta = (l2 - l1).abs();

    if (delta != 1) {
      // we want to animate only when adding/removing an item
      // if delta is larger than 1, then we can assume the List grew
      // in size a lot, for example by loading the items,
      // in this case, we do not want to animate these items.
      return _updateListWithoutAnimation();
    }

    if (l1 < l2) {
      _didInsertItem(outgoing, incoming);
    }

    if (l2 < l1) {
      _didRemoveItem(outgoing, incoming);
    }
  }

  void _didInsertItem(List<T> outgoing, List<T> incoming) {
    // find the item that is added in the incoming List.
    // if found, trigger the animation to insert
    for (var i = 0, l1 = outgoing.length, l2 = incoming.length; i < l2; i++) {
      final left = i < l1 ? outgoing[i] : null, right = incoming[i];

      if (left == null || !widget.areItemsTheSame(left, right)) {
        return _listKey.currentState?.insertItem(i);
      }
    }
  }

  void _didRemoveItem(List<T> outgoing, List<T> incoming) {
    // find the item that is missing in the incoming List.
    // if found, trigger the animation to remove
    for (var i = 0, l1 = outgoing.length, l2 = incoming.length; i < l1; i++) {
      final left = outgoing[i], right = i < l2 ? incoming[i] : null;

      if (right == null || !widget.areItemsTheSame(left, right)) {
        return _listKey.currentState?.removeItem(
          i,
          (context, animation) => _itemBuilder(context, i, animation, left),
        );
      }
    }
  }

  void _updateListWithoutAnimation() {
    // to force an update, without inserting or removing each
    // individual item in the List, we can simply reassign the GlobalKey
    // of the animated list.
    // typically, this reset is called whenever the state of the incoming
    // versus the outgoing Lists has changed too much.
    _listKey = GlobalKey<AnimatedListState>();
  }
}

class _SizeTransition extends AnimatedWidget {
  final Widget? child;

  const _SizeTransition({
    Key? key,
    required Animation<double> sizeFactor,
    this.child,
  }) : super(key: key, listenable: sizeFactor);

  @override
  Widget build(BuildContext context) {
    final sizeFactor = listenable as Animation<double>;

    return Opacity(
      opacity: sizeFactor.value * sizeFactor.value,
      child: Align(
        alignment: const AlignmentDirectional(-1.0, .0),
        heightFactor: sizeFactor.value,
        child: child,
      ),
    );
  }
}
